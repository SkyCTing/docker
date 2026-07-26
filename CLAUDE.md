# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A local dev stack (DNMP-style: Docker + Nginx + PHP multi-version + MySQL/Redis/PostgreSQL/ClickHouse/RabbitMQ/Qdrant). One `docker-compose.yml` drives everything; `.env` (gitignored, copied from `env.sample`) parameterizes versions, ports, IPs, and host paths via `${VAR}` substitution. `compose.sample.yml` is a reference template kept in sync with the active compose file.

## Configuration model

- **`.env` is the source of truth** for versions, host ports, static container IPs, and host path bindings. Always edit `.env` (and mirror structural changes to `env.sample`). Compose reads it automatically.
- **`SOURCE_DIR=/Users/sky.ding/SourceCode`** is bind-mounted to `/www` in containers — this is the host's *entire* SourceCode directory, **not** the repo's `./www`. So inside a container, the repo's own `www/index.php` lives at `/www/docker/www/index.php`. Per-project vhost roots (e.g. `/www/network/salegains`) point at subdirs of the host SourceCode dir.
- **Network**: custom bridge `default`, subnet `10.0.0.0/24`. Some services pin static IPs (`NGINX_IP=10.0.0.10`, `REDIS_IP=10.0.0.12`, …). Inter-container addressing uses service names (e.g. `php83`, `mysql`), not these IPs.

## Services: pull vs. build

Two kinds of services — know which is which before suggesting changes:

- **Pull-only** (`image:` only): `nginx` (official `nginx:${NGINX_VERSION}`), `certbot`, `mysql`, `redis`, `qdrant`, `clickhouse`. Changing their version = edit `.env`, `docker compose up -d --force-recreate <svc>`.
- **Build** (`build: context:`): `php83` (per-version Dockerfile under `services/php/<ver>/`), `postgresql` (adds pg_partman), `rabbitmq`, `nginx-cert-init`. Changing their Dockerfile/args = `docker compose build <svc>` then `up -d`. `compose up` does **not** rebuild an existing image unless you pass `--build`.

The old custom `mcskyding/nginx` image was removed — `nginx` is now the official image. `services/nginx/Dockerfile` was deleted; do not reintroduce a build for nginx.

## PHP images (multi-version)

- Each PHP version lives in `services/php/<ver>/` with its own `Dockerfile` and `extensions/install.sh`. `install.sh` conditionally compiles each extension listed in `PHP<VER>_EXTENSIONS` (env var, comma-separated). A runtime `install-php-extensions` binary is also installed for ad-hoc `docker exec -it php83 install-php-extensions <ext>`.
- `install.sh` swaps the alpine mirror to `CONTAINER_PACKAGE_URL` and builds extensions with `-j$(nproc)`. Cross-arch amd64 build via QEMU is ~4× slower than native arm64 — expect long build times on Apple Silicon.
- Multi-arch build & push (documented in README §5): `docker buildx build -t mcskyding/php:<tag> --platform linux/arm64,linux/amd64 --build-arg PHP_VERSION=php:<ver>-fpm-alpine --build-arg CONTAINER_PACKAGE_URL=... --build-arg TZ=... --build-arg PHP_EXTENSIONS=... . --push`. Requires `docker login --username mcskyding` with a Docker Hub **Personal Access Token** (Read & Write); a pull-only token fails with `insufficient_scope`.

## nginx

- `services/nginx/nginx.conf` includes `conf.d/my-test/*.conf` then `conf.d/localhost.conf`. `conf.d/` is bind-mounted (rw) — host edits reflect into the container after `docker exec nginx nginx -s reload`.
- **Only `localhost.conf` is git-tracked** under `conf.d/`. All other business vhosts (`my-test/`, `pianophile/`, …) are gitignored (`services/nginx/conf.d/*` + `!localhost.conf`) and kept locally. Treat them as user-owned external configs — don't edit unless asked.
- Bind-mounted include files: `fastcgi_params`, `fastcgi-php.conf`, `fastcgi.conf` (the last is a repo file that just does `include fastcgi_params;` — the official nginx image ships no `fastcgi.conf`, so confs that `include fastcgi.conf;` need this mount).

### nginx + php fastcgi: known flaky on restart (not yet fixed)

`fastcgi_pass phpXX:9000;` (bare hostname) is **eagerly resolved** at config-load time. If nginx starts before the php container's DNS is registered (e.g. after host reboot, `docker restart nginx`, or php container recreation), nginx aborts with `host not found in upstream "phpXX"` and enters a `Restarting (1)` loop it can't escape. `depends_on` is **not** set on nginx→php, so this race is live.

Recovery: `docker compose up -d --force-recreate nginx` (recreate, not `docker restart`, which just reruns the stale container). Root-cause fix options (user has so far declined to apply): per-conf `resolver 127.0.0.11; set $u "phpXX:9000"; fastcgi_pass $u;` (lazy resolution), or an entrypoint wait-loop on `getent hosts phpXX`.

## nginx-cert-init (localhost HTTPS auto-cert)

One-shot service (`services/nginx/cert-init/`) that runs before nginx (`depends_on: service_completed_successfully`). On each `up`, if `localhost.pem` is missing it signs `*.localhost.com localhost.com *.test.com test.com` (configurable via `CERT_DOMAINS`) using the **host's mkcert CA** mounted from `MKCERT_CAROOT` (env, points at `mkcert -CAROOT`). Browser-trusted because the CA was installed once via `mkcert -install`. If cert exists, exits 0 immediately (skip path). Requires `MKCERT_CAROOT` set in `.env`; on a new machine run `mkcert -install` first.

Known SAN gap: `CERT_DOMAINS` does not currently include bare `localhost`, so `https://localhost` (server_name `localhost`) shows a cert mismatch. X.509 forbids `*.*` / nested wildcards — to cover two-level subdomains (e.g. `*.salegains.test.com`) each base must be listed explicitly.

## postgresql + pg_partman

Custom image (`services/postgresql/Dockerfile`) on `postgres:${POSTGRES_VERSION}` that installs `pg_partman` (package name varies by PG major version: `pg-partman` for 17/18, `postgresql-<ver>-partman` older). `init/00-create-pg-partman.sql` auto-runs `CREATE EXTENSION pg_partman SCHEMA partman` **only when the data dir is empty** (first init). If `data/postgresql` already has data, the init script is skipped — manually run the `CREATE EXTENSION` in the target DB.

## Common commands

```bash
docker compose up -d                          # start all enabled services
docker compose up -d <svc>                    # start/recreate one service
docker compose up -d --force-recreate <svc>   # force fresh container (fixes stale mount/DNS state)
docker compose build <svc>                    # rebuild a build service (php/postgresql/rabbitmq/nginx-cert-init)
docker compose run --rm nginx-cert-init       # manually run cert-init once

docker exec nginx nginx -t                    # test nginx config
docker exec nginx nginx -s reload             # reload after editing conf.d/

docker exec -it php83 install-php-extensions <ext>   # ad-hoc PHP extension install
```

## Gotchas

- **macOS Docker Desktop bind mounts can go stale** (container created before a file was rewritten by another container): root inside container gets `Operation not permitted` on a dir/file that's fine on host. Fresh container reads it fine. Fix: `--force-recreate` the affected container. A throwaway `docker run --rm -v <dir>:/test alpine ls /test` isolates whether it's container-specific or mount-level.
- **`docker compose up -d <svc>` does not recreate** a container whose spec (image/volumes/env) is unchanged — it says "up-to-date" and leaves a sick container running. Only orchestration changes (e.g. adding `depends_on`) or `--force-recreate` actually replace it.
- **Multi-arch push to Docker Hub is flaky on macOS**: large blob uploads through vpnkit's proxy (`192.168.65.1:3128`) fail with `write: broken pipe`. Re-running hits cache and registry dedupes already-uploaded blobs; if it keeps failing, restart Docker Desktop, disable VPN, or push architectures separately then `docker manifest create` the list.
- **Redis** runs via custom entrypoint `["redis-server", "/etc/redis.conf"]`; its conf binds `0.0.0.0` (was `127.0.0.1 ... 10.0.0.12`, which failed with `Address not available` when the static IP wasn't on the interface at startup).
