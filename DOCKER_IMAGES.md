# Common Docker Images Setup Guide

This guide provides setup instructions for popular Docker images when installing them with docker_ynh. Use these as reference when filling out the installation form.

## Portainer (Docker Management)

**Image**: `portainer/portainer-ce:latest`  
**Container Port**: `9000`  
**Mount Docker Socket**: `true` (required)  
**Docker Options**: *(leave empty)*

Portainer needs access to the Docker daemon to manage containers. Enable "Mount Docker socket" during installation.

---

## Moodle (Learning Management System)

**Image**: `lthub/moodle:latest`  
**Container Port**: `80`  
**Mount Docker Socket**: `false`  
**Docker Options**: 

You need a separate database (MySQL/MariaDB). Choose one:

### Option A: Link to existing MariaDB container
```
-e MOODLE_DB_HOST=mariadb \
-e MOODLE_DB_NAME=moodle \
-e MOODLE_DB_USER=moodle \
-e MOODLE_DB_PASSWORD=your_secure_password
```

### Option B: Use external database
```
-e MOODLE_DB_HOST=mysql.example.com \
-e MOODLE_DB_NAME=moodle \
-e MOODLE_DB_USER=moodle \
-e MOODLE_DB_PASSWORD=your_password \
-e MOODLE_DB_PORT=3306
```

**Steps**:
1. First, install and configure MariaDB (via YunoHost or docker_ynh)
2. Create database: `moodle` with user `moodle`
3. Install Moodle with the docker_options above
4. Wait 5+ minutes on first start for initialization

---

## Gitea (Git Service)

**Image**: `gitea/gitea:latest`  
**Container Port**: `3000`  
**Mount Docker Socket**: `false`  
**Data Volume**: `true` (required)

**Docker Options** (optional, for database):
```
-e GITEA__database__DB_TYPE=mysql \
-e GITEA__database__HOST=mariadb:3306 \
-e GITEA__database__NAME=gitea \
-e GITEA__database__USER=gitea \
-e GITEA__database__PASSWD=password
```

If no database options provided, Gitea uses SQLite (suitable for small instances).

---

## Nextcloud (Cloud Storage)

**Image**: `nextcloud:apache`  
**Container Port**: `80`  
**Mount Docker Socket**: `false`  
**Data Volume**: `true` (required)

**Docker Options** (for external database):
```
-e MYSQL_DATABASE=nextcloud \
-e MYSQL_USER=nextcloud \
-e MYSQL_PASSWORD=your_password \
-e MYSQL_HOST=mariadb
```

Without database options, Nextcloud uses SQLite (acceptable for personal use).

---

## Nginx (Web Server)

**Image**: `nginx:alpine`  
**Container Port**: `80`  
**Mount Docker Socket**: `false`  
**Docker Options**: *(leave empty)*

Simple static web server. Use `mount_docker_socket = false` (default).

---

## WordPress (Blog/CMS)

**Image**: `wordpress:apache`  
**Container Port**: `80`  
**Mount Docker Socket**: `false`  
**Data Volume**: `true` (required for uploads)

**Docker Options** (required):
```
-e WORDPRESS_DB_HOST=mariadb:3306 \
-e WORDPRESS_DB_NAME=wordpress \
-e WORDPRESS_DB_USER=wordpress \
-e WORDPRESS_DB_PASSWORD=your_password
```

---

## Vaultwarden (Password Manager)

**Image**: `vaultwarden/server:latest`  
**Container Port**: `80`  
**Mount Docker Socket**: `false`  
**Data Volume**: `true` (required)

**Docker Options** (optional):
```
-e DOMAIN=https://vault.example.com \
-e SIGNUPS_ALLOWED=false
```

---

## General Tips

### Environment Variables
Use `-e VAR=value` to set environment variables:
```
-e DATABASE_URL=mysql://user:pass@host/db \
-e API_KEY=your_key_here \
-e DEBUG=false
```

### Volume Mounts
Mount additional directories with `-v`:
```
-v /path/on/host:/path/in/container \
-v /var/log/app:/logs
```

### Docker Socket Access
Only enable `mount_docker_socket = true` for:
- **Portainer** (Docker management)
- **Docker-in-Docker** setups
- Other container orchestration tools

**Warning**: This grants container root-equivalent access to the host.

### Finding Image Documentation
1. Visit `https://hub.docker.com/` and search for the image
2. Check the README for required environment variables
3. Look for examples in the "Environment Variables" section

### Database Setup
If your image needs a database:
1. Install MariaDB/MySQL first (via YunoHost or docker_ynh)
2. Create the database and user
3. Pass connection details via docker_options
4. Wait for initialization on first start

---

## Troubleshooting

### Container exits immediately
- Check logs: `journalctl -u docker_container__N -n 50`
- Verify required environment variables are set
- Check image documentation for mandatory config

### 503 Service Unavailable
- Container is still starting (wait 1-2 minutes)
- Check logs for initialization errors
- Verify port number matches image's listening port

### Permission Denied errors
- For socket mount issues: ensure `mount_docker_socket = true` is set
- For file access: check volume mount permissions

---

## Need Help?

- Check image README on Docker Hub
- Review journalctl logs: `journalctl -u docker_container__N -n 100`
- View container logs: `docker logs docker_container__N`
- Check NGINX error: `tail -50 /var/log/nginx/error.log`
