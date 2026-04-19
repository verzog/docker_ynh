#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

# Compute Docker run configuration based on install settings.
# Sets $docker_restart_policy, $docker_volume_opts, and $docker_network_opt for use in systemd template.
compute_docker_config() {
    local restart_policy="$1"
    local use_data_volume="$2"
    local data_dir="$3"
    local mount_docker_socket="${4:-0}"
    local docker_network="${5:-}"

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
    if [ "$mount_docker_socket" -eq 1 ]; then
        docker_volume_opts="$docker_volume_opts -v /var/run/docker.sock:/var/run/docker.sock"
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
