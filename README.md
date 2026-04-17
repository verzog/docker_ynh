# Docker Container for YunoHost

> **Warning:** This app is intended for advanced users. Docker containers are not integrated with YunoHost's SSO or LDAP — use native YunoHost apps when available.

## What does this app do?

This YunoHost package lets you pull any Docker image from [hub.docker.com](https://hub.docker.com) and run it as a managed systemd service on your YunoHost server. Each instance runs one container and is independently manageable via the YunoHost admin panel or CLI.

Features:
- Pull any public Docker image
- Manages the container as a systemd service (start/stop/restart via YunoHost Services page)
- Optional persistent data directory mounted at `/data` inside the container
- Pass custom Docker options (port mappings, environment variables, additional volumes)
- Multi-instance: deploy as many containers as you need
- Configurable restart policy

## Limitations

- No SSO or LDAP integration — containers run independently
- Does **not** work if YunoHost itself is running inside a Docker container
- Image upgrades require running the YunoHost upgrade action (which re-pulls `latest` or the pinned tag)
- Backup only covers the mounted `/data` volume; data stored exclusively inside the container is not backed up

## Installation

From the YunoHost admin panel or CLI:

```bash
yunohost app install https://github.com/verzog/docker_container_ynh
```

You will be prompted for:

| Parameter | Description |
|---|---|
| `container_name` | Human-readable label for this container |
| `image` | Docker image (e.g. `nginx:latest`) |
| `restart_policy` | `always`, `unless-stopped`, `on-failure`, or `no` |
| `use_data_volume` | Mount `$data_dir` to `/data` inside the container |
| `docker_options` | Extra `docker run` flags (ports, env vars, volumes) |

## Managing the container

```bash
# Start / stop / restart
yunohost service start docker_container
yunohost service stop docker_container

# View logs
journalctl -u docker_container -f

# Exec into the running container
docker exec -it docker_container bash
```

## Contributing

Pull requests are welcome at <https://github.com/verzog/docker_container_ynh>.
