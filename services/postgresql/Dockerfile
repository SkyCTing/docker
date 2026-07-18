# 语法: docker build --build-arg POSTGRES_VERSION=18 .
ARG POSTGRES_VERSION=18
FROM postgres:${POSTGRES_VERSION}

# pg_partman 的 Debian 包名随 PG 大版本变化（PG17+ 为 pg-partman，旧版为 postgresql-<ver>-partman）。
# 这里按主版本号自动适配，装不上时构建会直接报错，避免静默失败。
RUN set -eux; \
    case "${PG_MAJOR}" in \
        17|18) pkg="pg-partman" ;; \
        *) pkg="postgresql-${PG_MAJOR}-partman" ;; \
    esac; \
    apt-get update; \
    apt-get install -y --no-install-recommends postgresql-${PG_MAJOR}-partman 2>/dev/null || \
    apt-get install -y --no-install-recommends ${pkg}; \
    rm -rf /var/lib/apt/lists/*

# 把 init 脚本挂进容器，首次启动时自动在默认库里 CREATE EXTENSION。
COPY ./init/*.sql /docker-entrypoint-initdb.d/
