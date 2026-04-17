# Docker Container Manager

Deploy and manage any Docker container on your YunoHost server with integrated systemd service management.

## What This Does

This YunoHost package lets you run any Docker image from [Docker Hub](https://hub.docker.com) as a managed service on your YunoHost instance. Each installation creates one independent container that:

- Starts automatically when the server boots
- Can be managed via YunoHost admin panel (start/stop/restart)
- Stores persistent data in an optional mounted volume (`/data` inside container)
- Logs to systemd for easy monitoring
- Supports multi-instance deployment (run multiple containers side-by-side)

## Key Features

✅ **Pull any public Docker image** — nginx, PostgreSQL, your custom app, etc.  
✅ **Managed as systemd service** — Integrated with YunoHost service controls  
✅ **Optional persistent storage** — Mount `/data` volume for container data  
✅ **Custom Docker options** — Pass environment variables, port mappings, extra volumes  
✅ **Multi-instance support** — Deploy multiple containers independently  
✅ **Configurable restart policy** — always, unless-stopped, on-failure, or manual  
✅ **Integrated logging** — View container logs via `journalctl`  

## Important Limitations

⚠️ **No SSO/LDAP integration** — Containers run independently and don't integrate with YunoHost user accounts  
⚠️ **Not for YunoHost in Docker** — This app will not work if YunoHost itself is running inside a Docker container  
⚠️ **Backup covers mounted volumes only** — Data stored exclusively inside the container (not in `/data`) is not backed up  
⚠️ **Image upgrades reset container** — Running upgrade re-pulls the image and recreates the container  

## Quick Start

1. Install via YunoHost admin panel or CLI:
   ```bash
   yunohost app install https://github.com/verzog/docker_container_ynh
   ```

2. Choose your Docker image (e.g., `nginx:latest` or `postgres:15`)

3. Configure restart policy, data volume, and any custom Docker options

4. Start managing via YunoHost Services page or CLI

## Common Use Cases

- **Run a web server**: `nginx:latest`, `httpd:latest`
- **Run a database**: `postgres:15`, `mysql:8`, `mongo:latest`
- **Run a custom app**: Any image in your Docker registry
- **Run a utility**: `grafana/grafana`, `influxdb`, `adminer`

## Managing Your Container

### View logs
```bash
journalctl -u docker_container -f
```

### Execute commands inside
```bash
docker exec -it docker_container bash
```

### Restart
```bash
yunohost service restart docker_container
```

### Check status
```bash
yunohost service status docker_container
```

## Security & Permissions

Containers run as `root` by default (required for systemd management). For production use, consider configuring the container image to run as a non-root user via its Dockerfile or Docker options.

## Support & Contributing

Report issues or contribute improvements at: https://github.com/verzog/docker_container_ynh
