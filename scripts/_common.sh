#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

# Compute Docker run configuration based on install settings
# This function centralizes the logic to avoid duplication between install/upgrade
compute_docker_config() {
    local restart_policy="$1"
    local use_data_volume="$2"
    local data_dir="$3"
    
    # Map YunoHost restart policy to systemd Restart= directive
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
    
    # Build Docker volume mount options
    if [ "$use_data_volume" -eq 1 ]; then
        docker_volume_opts="-v $data_dir:/data"
    else
        docker_volume_opts=""
    fi
    
    # Export for use in calling scripts
    export systemd_restart docker_volume_opts
}

# Wrapper around standard systemd config helper
# Ensures consistent naming and parameter handling
ynh_config_add_systemd() {
    ynh_add_systemd_config --template="systemd.service"
}

# Wrapper around standard systemd removal helper
ynh_config_remove_systemd() {
    ynh_remove_systemd_config
}
