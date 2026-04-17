# Before Installing: Docker Container Manager

Please read these requirements and limitations before installing.

## System Requirements

### Docker Must Be Installed
This package requires Docker to be already installed on your YunoHost server:

```bash
sudo apt update
sudo apt install docker.io
```

Verify Docker is installed:
```bash
docker --version
```

### Docker Daemon Must Be Running
The Docker daemon (`docker.service`) must be active before you install this app. The install script will attempt to start it if it's not already running, but it's good to verify:

```bash
sudo systemctl status docker
```

If it's not running, start it:
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

### Root/Sudo Access Required
YunoHost admin access is required. The systemd service runs as root to manage Docker.

## Important Limitations

### ❌ No SSO/LDAP Integration
Containers deployed via this package **do not** integrate with YunoHost's centralized authentication (LDAP/OpenID Connect). Use native YunoHost apps instead if you need single sign-on.

### ❌ Not Compatible With YunoHost-in-Docker
If YunoHost itself is running inside a Docker container, this package will not work. This is due to Docker-in-Docker complications.

### ⚠️ Backup Only Covers Mounted Data
- **Backed up**: Files stored in `/data` directory inside the container (if you enable data volume)
- **NOT backed up**: Data stored in other container paths, databases, config files that exist only inside the container

**For database containers**, consider:
- Enabling the `/data` volume and ensuring your DB stores data there, OR
- Manually backing up database dumps before uninstalling

### ⚠️ Image Upgrades Reset the Container
When you run the YunoHost upgrade action:
1. The new image is pulled
2. The old container is removed and recreated
3. Any in-container state not stored in `/data` is lost

**Solution**: Make sure all persistent data is stored in the mounted `/data` volume or an external database.

## Recommendation: Test First

If this is your first time using Docker with YunoHost:
1. Start with a simple test image like `hello-world` to verify setup
2. Graduate to lightweight servers like `nginx:latest` or `httpd:latest`
3. Then deploy production workloads

## Questions?

- Check the admin guide: [Admin Documentation](ADMIN.md)
- Visit the project: https://github.com/verzog/docker_container_ynh
- YunoHost help: https://yunohost.org/en/help
