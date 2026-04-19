# Administrator Guide: Docker Container Manager

Guide for YunoHost admins managing Docker containers via this app.

## Installation Overview

When you install this package, you provide:

1. **Container name**: A label for your container (e.g., "my-app")
2. **Docker image**: The image to pull (e.g., `nginx:latest`)
3. **Restart policy**: How the container handles crashes:
   - `always` — Restart immediately if it exits (use for production)
   - `unless-stopped` — Restart unless explicitly stopped (recommended)
   - `on-failure` — Restart only if exit code is non-zero
   - `no` — Never auto-restart (manual management)
4. **Data volume**: Whether to mount persistent storage at `/data` (recommended for databases)
5. **Mount Docker socket**: Whether to bind-mount `/var/run/docker.sock` into the container. Required for tools like Portainer that manage Docker. **Warning**: this grants the container root-equivalent access to the host — only enable for trusted images.
6. **Docker network** (optional): A user-defined Docker network to attach the container to. Containers on the same network can resolve each other by name. Leave empty to use the default isolated bridge. The network is created automatically if it doesn't exist.
7. **Custom Docker options**: Extra flags for `docker run` (e.g., `-e VAR=value`). Do **not** add port mappings here — host port mapping is handled by the app.

## Managing Your Container

### View Status
```bash
yunohost service status docker_container
```

Or check raw systemd status:
```bash
systemctl status docker_container
```

### View Logs
Follow logs in real-time:
```bash
journalctl -u docker_container -f
```

View last 50 lines:
```bash
journalctl -u docker_container -n 50
```

View logs since a specific time:
```bash
journalctl -u docker_container --since "1 hour ago"
```

### Start / Stop / Restart
```bash
# Start the container
yunohost service start docker_container
systemctl start docker_container

# Stop the container
yunohost service stop docker_container
systemctl stop docker_container

# Restart the container (clean stop + start)
yunohost service restart docker_container
systemctl restart docker_container
```

### Execute Commands Inside
Access the running container's shell:
```bash
docker exec -it docker_container bash
```

Or run a single command:
```bash
docker exec docker_container ls -la /data
```

### Check Container Details
Get the container ID and image details:
```bash
docker ps -a | grep docker_container
```

Or use inspect for detailed info:
```bash
docker inspect docker_container
```

## Configuration Management

### View Current Settings
```bash
yunohost app info docker_container
```

This shows all stored installation settings.

### Update Docker Options
If you need to change environment variables, port mappings, or volume mounts:

```bash
yunohost app setting docker_container --key=docker_options --value="-e VAR=value -p 8080:80"
```

Then restart the container:
```bash
systemctl restart docker_container
```

### Change Restart Policy
```bash
yunohost app setting docker_container --key=restart_policy --value="unless-stopped"
systemctl restart docker_container
```

## Upgrading Your Container

When you run the YunoHost upgrade action:
1. The app stops the container
2. Pulls the latest image tag (or the pinned version)
3. Recreates the container with the new image

**Important**: Any data in the container that's not in the mounted `/data` volume will be lost.

To upgrade via CLI:
```bash
yunohost app upgrade docker_container
```

## Backup & Restore

### What Gets Backed Up
- The mounted `/data` volume (if enabled)
- The systemd service configuration
- Installation settings and metadata

### What Doesn't Get Backed Up
- Data stored in other container paths
- In-memory databases or caches
- Container logs

### Manual Backup (Before Uninstall)
For containers with important data, consider manual dumps:

**PostgreSQL example**:
```bash
docker exec docker_container pg_dump -U postgres mydb > backup.sql
```

**MySQL example**:
```bash
docker exec docker_container mysqldump -u root -p mydb > backup.sql
```

Copy these to your `/data` volume or external backup location.

## Troubleshooting

### Container Exits Immediately
Check the logs:
```bash
journalctl -u docker_container -n 100
```

**Common causes**:
- Image not found (typo in image name)
- Invalid Docker options
- Port already in use
- Missing required environment variables

### Port Already in Use
If you're mapping a port (e.g., `-p 8080:80`), ensure that port isn't already used:

```bash
sudo netstat -tulpn | grep 8080
```

Or try a different port:
```bash
yunohost app setting docker_container --key=docker_options --value="-p 8081:80"
```

### Out of Disk Space
Docker images and container data can grow quickly. Check disk usage:

```bash
df -h /var/lib/docker
```

Clean up unused images/containers:
```bash
docker image prune -a
docker container prune
```

### Network Issues Inside Container
If the container can't reach external networks:

```bash
docker exec docker_container ping 8.8.8.8
```

Check the host's DNS:
```bash
cat /etc/resolv.conf
```

You can pass DNS to the container:
```bash
yunohost app setting docker_container --key=docker_options --value="--dns 8.8.8.8"
```

## Multi-Instance Deployments

You can install this app multiple times for different containers:

```bash
yunohost app install https://github.com/verzog/docker_container_ynh
```

Each instance gets a unique app ID (e.g., `docker_container`, `docker_container__2`, `docker_container__3`).

Manage separately:
```bash
yunohost service restart docker_container__2
journalctl -u docker_container__2 -f
```

## Security Considerations

### Containers Run as Root
By default, containers run as the root user. For production:

1. Consider containerizing your app with a non-root user (in the Dockerfile), or
2. Pass a `--user` option in Docker options:
   ```bash
   yunohost app setting docker_container --key=docker_options --value="--user 1000:1000"
   ```

### Restrict Port Access
If you're mapping ports, ensure they're not exposed to the internet unless intended:

```bash
# Expose only to localhost
docker_options="-p 127.0.0.1:8080:80"

# Expose to all interfaces (use with caution)
docker_options="-p 8080:80"
```

### Resource Limits
Prevent containers from consuming all system resources:

```bash
docker_options="--memory 512m --cpus 0.5"
```

This limits the container to 512 MB RAM and 0.5 CPU cores.

## Advanced: Manual Container Management

If needed, you can manage the container directly with Docker commands (though YunoHost management will still track the service):

```bash
# Inspect the systemd unit
cat /etc/systemd/system/docker_container.service

# View the running container
docker ps | grep docker_container

# Get container logs directly
docker logs docker_container

# Stop via Docker directly
docker stop docker_container
```

But it's safer to use YunoHost commands so settings stay in sync.

## Support

For issues:
1. Check logs: `journalctl -u docker_container -f`
2. Verify Docker is running: `systemctl status docker`
3. Test the image manually: `docker run --rm nginx:latest`
4. Report issues: https://github.com/verzog/docker_container_ynh/issues
