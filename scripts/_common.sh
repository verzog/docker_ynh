#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

# Compute Docker run configuration based on install settings.
# This centralizes restart/volume logic to avoid duplication between install/upgrade.
compute_docker_config() {
    local restart_policy="$1"
    local use_data_volume="$2"
    local data_dir="$3"

    case "$restart_policy" in
        "always"|"unless-stopped")
            systemd_restart="always"
            ;;
        "on-failure")
            systemd_restart="on-failure"
            ;;
        *)
            systemd_restart="no"
            ;;
    esac

    if [ "$use_data_volume" -eq 1 ]; then
        docker_volume_opts="-v $data_dir:/data"
    else
        docker_volume_opts=""
    fi

    export systemd_restart docker_volume_opts
}
