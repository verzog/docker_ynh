# Common Docker Images Setup Guide

This guide provides setup instructions for popular Docker images when installing them with docker_ynh. Use these as reference when filling out the installation form.

## Multi-Container Setup with Docker Networks

If you need multiple containers to communicate (e.g., Moodle + MariaDB), use the **Docker Network** option:

### Example: Moodle + MariaDB on Same Network

**Step 1: Install MariaDB**
- Image: `mariadb:latest`
- Container Port: `3306`
- **Docker Network**: `education-network`
- Docker Options: `-e MARIADB_ROOT_PASSWORD=rootpass -e MARIADB_USER=moodle -e MARIADB_PASSWORD=moodlepass -e MARIADB_DATABASE=moodle`

**Step 2: Install Moodle**
- Image: `lthub/moodle:latest`
- Container Port: `80`
- **Docker Network**: `education-network`
- Docker Options:
  ```
  -e MOODLE_DB_HOST=docker_container__1 \
  -e MOODLE_DB_NAME=moodle \
  -e MOODLE_DB_USER=moodle \
  -e MOODLE_DB_PASSWORD=moodlepass
  ```

**Key points:**
- Both instances use the same Docker network name (`education-network`)
- Moodle references MariaDB by container name (`docker_container__1` — use the actual app instance name)
- Containers can reach each other directly without exposing ports to the host
- Database port is not accessible from outside the network

### Finding Container Names
After installation, check the app instance name via:
```bash
yunohost app list | grep docker_container
# Output: docker_container__1 (MariaDB)
# Output: docker_container__2 (Moodle)
```

Use the container name from "Instance Name" in your docker_options for the app container.

---

## MariaDB / MySQL (Database Server)

**Image**: `mariadb:latest` (or `mysql:8.0`)  
**Container Port**: `3306`  
**Mount Docker Socket**: `false`  
**Data Volume**: `true` (required for persistence)

**Docker Options** (customize as needed):
```
-e MARIADB_ROOT_PASSWORD=secure_root_password \
-e MARIADB_USER=appuser \
-e MARIADB_PASSWORD=secure_app_password \
-e MARIADB_DATABASE=appdb
```

**For use with Docker Network:**
- Install MariaDB first with a **Docker Network** name (e.g., `app-network`)
- Other containers on the same network can reach it using the container name
- Example: `-e DB_HOST=docker_container__1` (replace with actual MariaDB instance)

**Note**: Only expose this to the network, not to the internet (no NGINX frontend needed)

---

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

### Option A: Separate Docker containers on same network (Recommended)
1. Install MariaDB first with Docker Network: `moodle-network`
2. Install Moodle with Docker Network: `moodle-network`
3. Use docker_options (replace `docker_container__1` with actual MariaDB app name):
```
-e MOODLE_DB_HOST=docker_container__1 \
-e MOODLE_DB_NAME=moodle \
-e MOODLE_DB_USER=moodle \
-e MOODLE_DB_PASSWORD=your_secure_password
```

**Benefits**: Clean separation, secure (no port exposure), easy to scale

### Option B: External managed database
```
-e MOODLE_DB_HOST=mysql.example.com \
-e MOODLE_DB_NAME=moodle \
-e MOODLE_DB_USER=moodle \
-e MOODLE_DB_PASSWORD=your_password \
-e MOODLE_DB_PORT=3306
```

### Option C: Host IP (temporary workaround)
If you can't use networks, connect via host IP:
```
-e MOODLE_DB_HOST=192.168.1.100:8096 \
-e MOODLE_DB_NAME=moodle \
-e MOODLE_DB_USER=moodle \
-e MOODLE_DB_PASSWORD=your_password
```

**Steps for Option A (recommended)**:
1. Install MariaDB container first, note the instance name (e.g., `docker_container__1`)
2. Install Moodle with docker_options pointing to MariaDB's instance name
3. Both should be on the same `docker_network`
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

**Docker Options** (for docker network - replace `docker_container__1` with MariaDB instance):
```
-e MYSQL_DATABASE=nextcloud \
-e MYSQL_USER=nextcloud \
-e MYSQL_PASSWORD=your_password \
-e MYSQL_HOST=docker_container__1
```

**Docker Network**: Same as MariaDB instance (e.g., `nextcloud-network`)

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

**Docker Options** (replace `docker_container__1` with MariaDB instance):
```
-e WORDPRESS_DB_HOST=docker_container__1 \
-e WORDPRESS_DB_NAME=wordpress \
-e WORDPRESS_DB_USER=wordpress \
-e WORDPRESS_DB_PASSWORD=your_password
```

**Docker Network**: Same as MariaDB instance (e.g., `wordpress-network`)

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

### Docker Networks for Multi-Container Apps

Use the **Docker Network** option when you need multiple containers to communicate:

**Benefits:**
- ✅ Containers reach each other by name (no port exposure)
- ✅ More secure (database port not exposed to host)
- ✅ Easier to manage than using host IP
- ✅ Service discovery built-in

**Example workflow:**
1. Install database container with network name: `myapp-network`
2. Install app container with same network name: `myapp-network`
3. App references database by container name: `-e DB_HOST=docker_container__1`

**Note:** Containers on different networks cannot communicate. All containers must use the same network name.

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

### Database Container Setup
When running database as a separate container:
1. Install database first with a **Docker Network** name
2. Create database and user via docker_options environment variables
3. Install app container on the same network
4. Reference database by container name (not host IP)
5. Example: `-e DB_HOST=docker_container__1` where `docker_container__1` is the database instance

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
