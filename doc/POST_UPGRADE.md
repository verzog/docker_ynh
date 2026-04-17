# After Upgrading: Docker Container Manager

The Docker image has been re-pulled and the container recreated with the latest version.

## Verify the Container Is Running
```bash
yunohost service status __APP__
journalctl -u __APP__ -n 50
```

## If the Container Fails to Start
Check for issues with the new image version:
```bash
journalctl -u __APP__ -n 100
docker logs __APP__
```

If the new version requires new configuration (environment variables, different ports), update your Docker options:
```bash
yunohost app setting __APP__ --key=docker_options --value="<new_options>"
systemctl restart __APP__
```
