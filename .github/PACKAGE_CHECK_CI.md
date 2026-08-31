# Running the full YunoHost test suite (`package_check`) in CI

The default `App linter` workflow only checks static things (manifest, bash
syntax). The *real* YunoHost integration tests — install, remove, upgrade,
backup/restore, `change_url`, multi-instance, port-already-used — are run by
[`package_check`](https://github.com/YunoHost/package_check), which installs the
package on a real YunoHost system and drives the scenarios in
[`tests.toml`](../tests.toml).

`.github/workflows/package_check.yml` runs it — but **only on a self-hosted
runner** you provide, because `package_check` cannot run on GitHub-hosted
runners.

## Why a self-hosted runner is required

- `package_check` needs **LXD or Incus** to build a clean YunoHost container.
- It **conflicts with Docker on the host** (both want dnsmasq on port 53), and
  the upstream docs recommend a dedicated machine.
- **This package is special:** the app under test launches *Docker* containers
  *inside* the LXD test container, so the container must allow **nested
  containers** (`security.nesting=true`, Docker-in-LXD). A stock runner can't do
  this.

GitHub-hosted runners meet none of these, so the workflow targets a runner
labelled `yunohost`. Until you register one, the job never starts — it neither
runs nor blocks PRs.

## One-time runner host setup

Use a dedicated VM or box (Debian/Ubuntu recommended). **Do not** run this on a
host you also use for Docker workloads — LXD's networking will fight Docker's.

1. **Install and initialise LXD** (Incus works too):
   ```bash
   sudo apt update && sudo apt install -y lynx jq btrfs-progs
   sudo snap install lxd        # or: sudo apt install lxd
   sudo lxd init                # accept defaults; BTRFS storage is recommended
   sudo usermod -aG lxd "$USER" # then log out/in so the group takes effect
   ```

2. **Allow nested containers** so the app's Docker containers can start inside
   the test container. `package_check` uses an LXD profile/base image; ensure
   nesting is on for the containers it creates, e.g. set it on the default
   profile of the project it uses:
   ```bash
   lxc profile set default security.nesting true
   ```
   (If `package_check` uses a dedicated profile/remote, set `security.nesting`
   and `security.privileged` there instead. Verify a quick `lxc launch` +
   `docker run hello-world` works inside a nested container before relying on
   CI.)

3. **Smoke-test `package_check` by hand** once, from a clone of this repo:
   ```bash
   git clone https://github.com/YunoHost/package_check
   ./package_check/package_check.sh /path/to/this/repo
   ```
   Confirm it reaches a real pass/fail (not an LXD/nesting error) before wiring
   up CI.

## Register the GitHub Actions runner

On the same host, add a self-hosted runner to the repository and give it the
`yunohost` label the workflow expects:

1. In GitHub: **Settings → Actions → Runners → New self-hosted runner**, pick
   Linux, and follow the download/configure snippet it shows.
2. When configuring, add the label:
   ```bash
   ./config.sh --url https://github.com/verzog/docker_ynh --token <TOKEN> \
     --labels yunohost
   ```
3. Run it as a service so it survives reboots:
   ```bash
   sudo ./svc.sh install
   sudo ./svc.sh start
   ```

The runner user must be in the `lxd` (or `incus-admin`) group from the step
above.

## Triggering the tests

- **Manually:** Actions tab → *Package check (full YunoHost tests)* → **Run
  workflow**, on any branch.
- **On a pull request:** add the **`package_check`** label to the PR. (Create
  the label once under Issues → Labels if it doesn't exist.)

Results are printed in the job log and uploaded as the `package-check-results`
artifact (`Test_results.log` and any `results/`), retained for 14 days.

## Notes

- Runs can take a while — several install/upgrade/backup cycles — hence the
  120-minute job timeout.
- Keep the runner host patched; `package_check` pulls the latest YunoHost into
  fresh containers on each run.
- This does **not** replace YunoHost's official CI
  (`ci-apps.yunohost.org`), which is the route for apps submitted to the
  official catalog. It's a self-hosted equivalent for this fork.
