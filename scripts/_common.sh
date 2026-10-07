#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

# Curated catalog of vetted free-software images.
#
# Only images listed here can be installed. This keeps the running software
# reviewable: every entry is a known free-software application with a recorded
# license, so the app no longer pulls arbitrary (and potentially non-free or
# unethical) images from Docker Hub.
#
# Format: key -> "image_ref|spdx_license|container_port"
# Image refs are pinned to explicit version tags (never ":latest") so installs
# are reproducible. Maintainers: when bumping a tag, verify it on Docker Hub and
# — ideally — pin by "@sha256:<digest>" for full immutability.
declare -A CURATED_IMAGES=(
    [vaultwarden]="vaultwarden/server:1.32.7|AGPL-3.0-only|80"
    [gitea]="gitea/gitea:1.22.6|MIT|3000"
    [freshrss]="freshrss/freshrss:1.24.3|AGPL-3.0-only|80"
    [uptime-kuma]="louislam/uptime-kuma:1.23.16|MIT|3001"
    [ghost]="ghost:5.114.1|MIT|2368"
    # Moodle 5.2 series (latest stable patch).
    [moodle]="erseco/alpine-moodle:v5.2.4|GPL-3.0-or-later|8080"
    # Moodle 5.3 LTS — released 2026-10-05; erseco published v5.3.0 on 2026-10-06.
    # Installable alongside 5.2.x via the "moodle-53" key.
    [moodle-53]="erseco/alpine-moodle:v5.3.0|GPL-3.0-or-later|8080"
    # Community image — no official GibbonEdu image exists. Unmaintained
    # (last updated 2024-01, pinned to v26); verify before relying on it.
    [gibbon]="kerrongordon/gibbon:26.0.00|GPL-3.0-or-later|80"
    [nginx]="nginx:1.27.4-alpine|BSD-2-Clause|80"
    [mariadb]="mariadb:11.4.5|GPL-2.0-only|3306"
    [postgres]="postgres:16.8-alpine|PostgreSQL|5432"
)

# Resolve a curated image key into its pinned reference, license and port.
# Sets (and exports) $image_ref, $image_license and $container_port.
# Dies if the key is not on the allowlist.
resolve_curated_image() {
    local key="$1"
    local entry="${CURATED_IMAGES[$key]:-}"

    if [ -z "$entry" ]; then
        ynh_die "Image '$key' is not on the curated free-software allowlist. Allowed images: ${!CURATED_IMAGES[*]}"
    fi

    image_ref="${entry%%|*}"
    local rest="${entry#*|}"
    image_license="${rest%%|*}"
    container_port="${rest##*|}"

    export image_ref image_license container_port
}

#=================================================
# MOODLE-SPECIFIC HELPERS
#=================================================
# The erseco/alpine-moodle image needs extra care that the generic path does not:
# it keeps state outside /data, ships only 64-bit variants, and defaults to a
# well-known admin password. These helpers are gated on the Moodle keys so every
# other curated image behaves exactly as before.

# The container runs as the Alpine "nobody" user (uid/gid 65534) and starts
# non-root, so it cannot chown its bind mounts — the host dirs must already be
# owned by this id or Moodle cannot write uploads/sessions.
MOODLE_CONTAINER_UID=65534

# Return 0 if the given curated key is a Moodle image.
is_moodle_image() {
    case "$1" in
        moodle | moodle-53) return 0 ;;
        *) return 1 ;;
    esac
}

# Refuse Moodle on a 32-bit host. From v5.2.4 / v5.3.0 the image publishes only
# 64-bit platforms (amd64/arm64/ppc64el/s390x); on i386/armhf the pinned tag
# cannot be pulled. Call this BEFORE pulling (install) and BEFORE stopping the
# running service (upgrade) so a 32-bit box is rejected without downtime.
moodle_arch_guard() {
    is_moodle_image "$1" || return 0
    local arch
    arch="$(dpkg --print-architecture 2>/dev/null || echo unknown)"
    case "$arch" in
        armhf | armel | i386 | i686)
            ynh_die "Moodle (image key '$1') is 64-bit only: erseco/alpine-moodle v5.2.4+/v5.3.0 publish no 32-bit variant, so the image cannot be pulled on this '$arch' host. Install Moodle on a 64-bit (amd64/arm64) server."
            ;;
    esac
}

# Create and permission Moodle's persistent state directories under $data_dir.
prepare_moodle_state_dirs() {
    local data_dir="$1"
    mkdir -p "$data_dir/moodledata" "$data_dir/html"
    chown "$MOODLE_CONTAINER_UID:$MOODLE_CONTAINER_UID" "$data_dir/moodledata" "$data_dir/html"
}

# Compute Docker run configuration based on install settings.
# Sets $docker_restart_policy, $docker_volume_opts, and $docker_network_opt for use in systemd template.
compute_docker_config() {
    local restart_policy="$1"
    local use_data_volume="$2"
    local data_dir="$3"
    local docker_network="${4:-}"
    local image_key="${5:-}"

    case "$restart_policy" in
        "always")
            docker_restart_policy="always"
            ;;
        "unless-stopped")
            docker_restart_policy="unless-stopped"
            ;;
        "on-failure")
            docker_restart_policy="on-failure:5"
            ;;
        *)
            docker_restart_policy="no"
            ;;
    esac

    docker_volume_opts=""
    if [ "$use_data_volume" -eq 1 ]; then
        docker_volume_opts="-v $data_dir:/data"
    fi

    # Moodle keeps uploads/backups in /var/www/moodledata and code/plugins/config
    # in /var/www/html, neither relocatable by env var. The container is recreated
    # on every restart (conf/systemd.service runs `docker rm` on stop), so without
    # these bind mounts Moodle loses all uploaded files and installed plugins on
    # the first restart or upgrade. (Moodle also requires the data volume — install
    # dies if it is disabled — so these mounts always accompany the /data mount.)
    if is_moodle_image "$image_key" && [ "$use_data_volume" -eq 1 ]; then
        docker_volume_opts="$docker_volume_opts -v $data_dir/moodledata:/var/www/moodledata -v $data_dir/html:/var/www/html"
    fi

    docker_network_opt=""
    if [ -n "$docker_network" ]; then
        docker_network_opt="--network=$docker_network"
    fi

    export docker_restart_policy docker_volume_opts docker_network_opt
}

# Wait up to $timeout seconds for a TCP port on localhost to accept connections.
# Returns 0 when the port is ready, 1 on timeout.
wait_for_port() {
    local port="$1"
    local timeout="${2:-30}"
    local elapsed=0
    while ! (echo > /dev/tcp/127.0.0.1/"$port") 2>/dev/null; do
        if [ "$elapsed" -ge "$timeout" ]; then
            return 1
        fi
        sleep 1
        elapsed=$((elapsed + 1))
    done
    return 0
}
