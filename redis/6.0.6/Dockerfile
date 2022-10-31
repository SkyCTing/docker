FROM alpine:3.12

MAINTAINER "Sky Ting"

RUN addgroup -S -g 2000 httpd && adduser -S -G httpd -u 2000 httpd

# set repositories
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN apk add --no-cache 'su-exec>=0.2'

ENV REDIS_VERSION 6.0.6
ENV REDIS_DOWNLOAD_URL http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz

RUN set -eux; \
    \
    apk add --no-cache --virtual .build-deps \
        coreutils \
        gcc \
        linux-headers \
        make \
        musl-dev \
        openssl-dev \
        tzdata \
        wget; \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
    echo "Asia/Shanghai" > /etc/timezone; \
    mkdir -p /opt/src/redis; \
    mkdir -p /opt/app/redis/etc; \
    mkdir -p /opt/app/redis/var; \
    mkdir -p /opt/app/redis/db; \
    cd /opt/src/; \
    wget -O redis.tar.gz "$REDIS_DOWNLOAD_URL"; \
    tar -xzf redis.tar.gz -C /opt/src/redis --strip-components=1; \
    \
    grep -E '^ *createBoolConfig[(]"protected-mode",.*, *1 *,.*[)],$' /opt/src/redis/src/config.c; \
    sed -ri 's!^( *createBoolConfig[(]"protected-mode",.*, *)1( *,.*[)],)$!\10\2!' /opt/src/redis/src/config.c; \
    grep -E '^ *createBoolConfig[(]"protected-mode",.*, *0 *,.*[)],$' /opt/src/redis/src/config.c; \
    \
    export BUILD_TLS=yes; \
    make PREFIX=/opt/app/redis -C /opt/src/redis -j "$(nproc)" all; \
    make -C /opt/src/redis install PREFIX=/opt/app/redis; \
    \
    serverMd5="$(md5sum /opt/app/redis/bin/redis-server | cut -d' ' -f1)"; export serverMd5; \
    find /opt/app/redis/bin/redis* -maxdepth 0 \
        -type f -not -name redis-server \
        -exec sh -eux -c ' \
            md5="$(md5sum "$1" | cut -d" " -f1)"; \
            test "$md5" = "$serverMd5"; \
        ' -- '{}' ';' \
        -exec ln -svfT 'redis-server' '{}' ';' \
    ; \
    \
    rm -rf /opt/src/redis; \
    \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --no-network --virtual .redis-rundeps $runDeps; \
    apk del --no-network .build-deps; \
    ln -s /opt/app/redis/bin/* /usr/local/bin/; \
    redis-cli --version; \
    redis-server --version

RUN chown httpd:httpd /opt/app/redis/db; \
    mkdir -p /opt/logs/redis; \
    chown httpd:httpd /opt/logs/redis/;

WORKDIR /opt/app/redis

COPY docker-entrypoint.sh /usr/local/bin/
COPY redis.conf /opt/app/redis/etc
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 6379
CMD ["redis-server","/opt/app/redis/etc/redis.conf"]