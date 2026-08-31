# Curated Images Setup Guide

This guide covers the **vetted free-software images** that `docker_ynh` can install. You pick an application by its key in the install form (the `image` select); the package owns the exact image reference, pinned version and internal port — so there is no "Container Port" or "Mount Docker socket" field to set anymore.

The full pinned list lives in `scripts/_common.sh` (`CURATED_IMAGES`):

| Key | Image | License | Internal port |
|---|---|---|---|
| `vaultwarden` | `vaultwarden/server` | AGPL-3.0-only | 80 |
| `gitea` | `gitea/gitea` | MIT | 3000 |
| `freshrss` | `freshrss/freshrss` | AGPL-3.0-only | 80 |
| `uptime-kuma` | `louislam/uptime-kuma` | MIT | 3001 |
| `ghost` | `ghost` | MIT | 2368 |
| `moodle` | `erseco/alpine-moodle` | GPL-3.0-or-later | 8080 |
| `gibbon` † | `kerrongordon/gibbon` | GPL-3.0-or-later | 80 |
| `nginx` | `nginx` (alpine) | BSD-2-Clause | 80 |
| `mariadb` | `mariadb` | GPL-2.0-only | 3306 |
| `postgres` | `postgres` (alpine) | PostgreSQL | 5432 |

† `gibbon` uses a **community, unofficial** image — no official GibbonEdu image exists, and this one is unmaintained (last updated 2024-01, pinned to v26).

> Want an image that isn't here? Open a pull request adding it to `CURATED_IMAGES` (it must be free software with a clear license), or run it outside the official path via `yunohost app install <git_url>` / a custom catalog.

## Multi-Container Setup with Docker Networks

Some apps need a database. Install each as its own instance and put them on a shared **Docker Network** so they reach each other by container name.

### Example: Ghost + MariaDB on the same network

**Step 1 — install `mariadb`**
- Image (select): `mariadb`
- **Docker Network**: `blog-network`
- Docker Options:
  ```
  -e MARIADB_ROOT_PASSWORD=rootpass -e MARIADB_USER=ghost -e MARIADB_PASSWORD=ghostpass -e MARIADB_DATABASE=ghost
  ```

**Step 2 — install `ghost`**
- Image (select): `ghost`
- **Docker Network**: `blog-network`
- Docker Options (replace `docker_container__1` with the actual MariaDB instance name):
  ```
  -e database__client=mysql \
  -e database__connection__host=docker_container__1 \
  -e database__connection__user=ghost \
  -e database__connection__password=ghostpass \
  -e database__connection__database=ghost
  ```

**Key points:**
- Both instances use the same Docker network name (`blog-network`)
- Ghost references MariaDB by container/instance name, not host IP
- The database port stays on the network and is never exposed to the host or internet

### Finding container names
```bash
yunohost app list | grep docker_container
# e.g. docker_container__1 (mariadb)
#      docker_container__2 (ghost)
```

---

## Per-image notes

### `vaultwarden` — Password manager (AGPL-3.0)
- Data Volume: keep enabled (required for persistence)
- Useful options: `-e SIGNUPS_ALLOWED=false` (and set `-e DOMAIN=https://vault.example.com` to your real URL)

### `gitea` — Git hosting (MIT)
- Data Volume: keep enabled (required)
- Uses SQLite by default (fine for small instances). For MariaDB/Postgres, put both on a Docker network and pass `-e GITEA__database__*` options.

### `freshrss` — RSS reader (AGPL-3.0)
- Data Volume: keep enabled
- Pairs well with `postgres` on a shared network for larger feeds.

### `uptime-kuma` — Uptime monitoring (MIT)
- Data Volume: keep enabled (stores monitors/history)
- No database container needed.

### `ghost` — Blogging platform (MIT)
- Needs MariaDB — see the multi-container example above.

### `moodle` — Learning management system (GPL-3.0)
- Image: `erseco/alpine-moodle` (community wrapper, MIT; Moodle itself is GPL-3.0). Internal port **8080**.
- **Version:** currently pinned to Moodle **5.2.2** (latest stable 5.2.x). YunoHost's native `moodle_ynh` package doesn't yet ship the 5.2/5.3 series, so this Docker path is the way to test them.
- **Moodle 5.3 (LTS):** staged but not yet enabled. Moodle 5.3 releases 2026-10-05 and the `erseco/alpine-moodle` image has no `v5.3.x` tag yet, so there is nothing to pin. A commented `moodle-53` slot is prepared in [`scripts/_common.sh`](./scripts/_common.sh); once upstream publishes a 5.3 tag, uncomment it (updating the patch level) and add `moodle-53` to the `image` choices in `manifest.toml` to install 5.2.x and 5.3.x side by side.
- **Needs a database.** Install `postgres` (recommended) or `mariadb` on a shared Docker network, then point Moodle at it.
- ⚠️ **Persist the database.** The container is recreated on every service restart/upgrade (`conf/systemd.service` runs `docker rm` on stop), so **only files under the package's `/data` volume survive**. A database stores its files *outside* `/data` by default (`/var/lib/postgresql/data` for Postgres, `/var/lib/mysql` for MariaDB), so each DB instance below must relocate or bind-mount its data directory — otherwise the database is wiped on the next restart. Keep the **Data Volume** enabled on the DB instance.
- **PostgreSQL (recommended — the image's default engine).** The `erseco/alpine-moodle` image defaults to `DB_TYPE=pgsql` and recommends PostgreSQL for production. Install a `postgres` instance on the shared network and point Moodle at it. Example, with a `postgres` instance named `docker_container__1` on network `edu-network`:
  ```
  -e DB_TYPE=pgsql \
  -e DB_HOST=docker_container__1 \
  -e DB_PORT=5432 \
  -e DB_NAME=moodle \
  -e DB_USER=moodle \
  -e DB_PASS=moodlepass \
  -e SITE_URL=https://YOURDOMAIN.tld/PATH
  ```
  (The matching PostgreSQL instance is installed with `-e POSTGRES_DB=moodle -e POSTGRES_USER=moodle -e POSTGRES_PASSWORD=moodlepass -e PGDATA=/data/pgdata`. `PGDATA=/data/pgdata` is what makes the cluster persistent — it stores the data in a subdirectory of the package's `/data` volume, which survives the container being recreated. Without it the database lives in the container's ephemeral layer and is lost on restart.)
- **MariaDB (alternative).** To use MariaDB instead, install a `mariadb` instance on the shared network and set `DB_TYPE=mariadb` / port `3306`. Example, with a `mariadb` instance named `docker_container__1`:
  ```
  -e DB_TYPE=mariadb \
  -e DB_HOST=docker_container__1 \
  -e DB_NAME=moodle \
  -e DB_USER=moodle \
  -e DB_PASS=moodlepass \
  -e SITE_URL=https://YOURDOMAIN.tld/PATH
  ```
  (The matching MariaDB instance is installed with `-e MARIADB_DATABASE=moodle -e MARIADB_USER=moodle -e MARIADB_PASSWORD=moodlepass -e MARIADB_ROOT_PASSWORD=rootpass`. Unlike Postgres, the MariaDB image can't relocate its data directory by env var, so add a persistent bind mount for `/var/lib/mysql` in that instance's **Docker Options** field — e.g. `-v /home/yunohost.app/<mariadb-instance>/mysql:/var/lib/mysql` (any persistent host path works). Without it the database is wiped when the container is recreated on restart.)
- For a quick single-container trial only, the image also supports SQLite via `-e DB_TYPE=sqlite3` — not recommended for real use.
- First boot runs the Moodle installer and can take several minutes.

### `gibbon` — School management platform (GPL-3.0)
- ⚠️ **Community, unofficial, unmaintained image** (`kerrongordon/gibbon`, last updated 2024-01, pinned to `26.0.00` while upstream Gibbon is well beyond v26). No official GibbonEdu image exists. Treat as best-effort, not vetted to the same standard as the other entries. Internal port **80**.
- Needs a MySQL/MariaDB database. Install `mariadb` on a shared network and complete Gibbon's web installer pointing at it (Gibbon configures the DB through its first-run wizard rather than env vars).

### `nginx` — Static web server (BSD-2-Clause)
- Mount your site into the container via the data volume or an extra `-v` mount.

### `mariadb` / `postgres` — Databases
- Backend services for the apps above. Install them with a **Docker Network** name and **no public access** — they don't need an NGINX frontend.
- Provision the database/user via environment variables (`-e MARIADB_*` or `-e POSTGRES_*`).

---

## General Tips

### Environment variables
```
-e VAR=value -e ANOTHER=value
```

### Extra volume mounts
```
-v /path/on/host:/path/in/container
```

### Security
- Containers run with `--security-opt no-new-privileges` and have **no** access to the Docker socket (the socket mount option was removed). Tools that require the Docker socket (e.g. Portainer) are intentionally not supported here — run those outside the official path if you need them.
- Prefer images that run as a non-root user where possible.

---

## Troubleshooting

### Container exits immediately
- Check logs: `journalctl -u docker_container__N -n 50`
- Verify required environment variables are set (see per-image notes)

### 503 Service Unavailable
- Container is still starting (wait 1–2 minutes)
- Check logs for initialization errors

### Database connection fails (multi-container)
- Confirm both instances share the same Docker network name
- Confirm the app references the database by its instance name, not host IP

---

## Need Help?

- Review logs: `journalctl -u docker_container__N -n 100`
- View container logs: `docker logs docker_container__N`
- Check NGINX error log: `tail -50 /var/log/nginx/error.log`
