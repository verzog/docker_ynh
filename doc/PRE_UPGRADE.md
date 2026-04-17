# Before Upgrading: Docker Container Manager

Please read this before running the upgrade action.

## What Happens During Upgrade

1. The running container is stopped
2. The Docker image is re-pulled (fetches the latest version of the configured tag)
3. The old container is removed
4. A new container is created with the updated image

## Important: Data Preservation

**Data stored in the `/data` volume is preserved** across upgrades.

**Data stored inside the container only** (outside `/data`) **will be lost**. Ensure all persistent data is in the mounted `/data` volume or an external location before upgrading.

## Recommendation

If your container holds important data not in `/data`, create a manual backup first:

```bash
# Example: backup a database
docker exec YOUR_CONTAINER pg_dump -U postgres mydb > /path/to/backup.sql
```
