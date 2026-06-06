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

# Compute Docker run configuration based on install settings.
# Sets $docker_restart_policy, $docker_volume_opts, and $docker_network_opt for use in systemd template.
compute_docker_config() {
    local restart_policy="$1"
    local use_data_volume="$2"
    local data_dir="$3"
    local docker_network="${4:-}"

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
