# Docker Container Manager

Deploy and manage a **vetted free-software** Docker container on your YunoHost server with integrated systemd service management.

## What This Does

This YunoHost package lets you run one of a **curated list of vetted free-software images** as a managed service on your YunoHost instance. Rather than pulling an arbitrary image from Docker Hub, you pick an application from a short allowlist; the package owns the exact image reference, version and internal port. Each installation creates one independent container that:

- Starts automatically when the server boots
- Can be managed via YunoHost admin panel (start/stop/restart)
- Stores persistent data in an optional mounted volume (`/data` inside container)
- Logs to systemd for easy monitoring
- Supports multi-instance deployment (run multiple containers side-by-side)

## Curated free-software images

Only the following images can be installed. Each is a known free-software application, pinned to an explicit version (never `:latest`) so installs are reproducible and the running software is reviewable.

| Choice | Image | License | Internal port |
|---|---|---|---|
| `vaultwarden` | `vaultwarden/server` | AGPL-3.0-only | 80 |
| `gitea` | `gitea/gitea` | MIT | 3000 |
| `freshrss` | `freshrss/freshrss` | AGPL-3.0-only | 80 |
| `uptime-kuma` | `louislam/uptime-kuma` | MIT | 3001 |
| `ghost` | `ghost` | MIT | 2368 |
| `nginx` | `nginx` (alpine) | BSD-2-Clause | 80 |
| `mariadb` | `mariadb` | GPL-2.0-only | 3306 |
| `postgres` | `postgres` (alpine) | PostgreSQL | 5432 |

The exact pinned versions live in `scripts/_common.sh` (the `CURATED_IMAGES` table). To propose adding an image, open a pull request — it should be free software with a clear license.

## Key Features

✅ **Vetted free-software images only** — reproducible, license-recorded, pinned versions
✅ **Managed as systemd service** — Integrated with YunoHost service controls
✅ **Optional persistent storage** — Mount `/data` volume for container data
✅ **Custom Docker options** — Pass environment variables and extra volumes
✅ **Multi-instance support** — Deploy multiple containers independently
✅ **Configurable restart policy** — always, unless-stopped, on-failure, or manual
✅ **Integrated logging** — View container logs via `journalctl`
✅ **Hardening defaults** — `--security-opt no-new-privileges`, no Docker-socket mount, systemd sandboxing

## Important Limitations

⚠️ **Curated images only** — Arbitrary Docker Hub images are intentionally not installable here. To run an unlisted image, use a custom catalog or `yunohost app install <git_url>`.
⚠️ **No SSO/LDAP integration** — Containers run independently and don't integrate with YunoHost user accounts
⚠️ **Not for YunoHost in Docker** — This app will not work if YunoHost itself is running inside a Docker container
⚠️ **Backup covers mounted volumes only** — Data stored exclusively inside the container (not in `/data`) is not backed up
⚠️ **Image upgrades recreate the container** — Running upgrade re-pulls the pinned image and recreates the container

## Quick Start

1. Install via YunoHost admin panel or CLI:
   ```bash
   yunohost app install https://github.com/verzog/docker_ynh
   ```

2. Choose an application from the curated list (e.g., `nginx` or `freshrss`)

3. Configure restart policy, data volume, Docker network, and any custom Docker options

4. Start managing via YunoHost Services page or CLI

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

Containers run with `--security-opt no-new-privileges` and **without** access to the Docker socket. The systemd unit applies additional sandboxing to the `docker run` supervisor process. For production use, prefer images that run as a non-root user, and pass any image-specific hardening via the custom Docker options field.

## Support & Contributing

Report issues or contribute improvements at: https://github.com/verzog/docker_ynh
