# After Installation: Docker Container Manager

The app URL is not applicable for this package — Docker containers do not have a web interface managed by YunoHost.

The app install dir is `__INSTALL_DIR__`

## Next Steps

Your Docker container is now running as a managed systemd service.

### View Logs
```bash
journalctl -u __APP__ -f
```

### Execute Commands Inside the Container
```bash
docker exec -it __APP__ bash
```

### Manage via YunoHost
Start/stop/restart the container from the YunoHost admin panel under **Services**, or via CLI:
```bash
yunohost service restart __APP__
```

### Configure Additional Options
To add port mappings, environment variables, or extra volumes:
```bash
yunohost app setting __APP__ --key=docker_options --value="-p 127.0.0.1:8080:80 -e MY_VAR=value"
systemctl restart __APP__
```
