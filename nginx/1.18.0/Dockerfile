FROM alpine:3.11
MAINTAINER "Sky Ting"

ENV NGINX_VERSION 1.18.0

# set repositories
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

# set timezone
RUN apk add --virtual .timezone tzdata; \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
    echo "Asia/Shanghai" > /etc/timezone; \
    # Bring in curl and ca-certificates to make registering on DNS SD easier
    apk add --no-cache curl ca-certificates; \
    apk del --no-network .timezone; \
# create nginx user/group first, to be consistent throughout docker variants
    addgroup -g 2000 -S httpd; \
    adduser -u 2000 -G httpd -S -D -H httpd httpd; \
# mkdir
    mkdir -p /opt/src; \
    mkdir -p /opt/app/nginx/cache/client_temp; \
    mkdir -p /opt/app/nginx/conf/conf.d; \
    mkdir -p /opt/case; \
    mkdir -p /opt/logs/nginx; \
    mkdir -p /opt/app/nginx/var; \
    mkdir -p /opt/app/nginx/conf/cert;

RUN GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8; \
    apk add --no-cache --virtual .build-deps \
        gcc \
        libc-dev \
        make \
        openssl-dev \
        pcre-dev \
        zlib-dev \
        linux-headers \
        curl \
        gnupg \
        libxslt-dev \
        gd-dev \
        geoip-dev; \
    curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz; \
    curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc  -o nginx.tar.gz.asc; \
    curl -fSL https://openresty.org/download/openresty-1.15.8.3.tar.gz -o openresty.1.15.8.3.tar.gz; \
    CONFIG=" \
        --prefix=/opt/app/nginx \
        --sbin-path=/opt/app/nginx/sbin/nginx \
        --modules-path=/opt/app/nginx/modules \
        --conf-path=/opt/app/nginx/conf/nginx.conf \
        --error-log-path=/opt/logs/nginx/error.log \
        --http-log-path=/opt/logs/nginx/access.log \
        --pid-path=/opt/app/nginx/var/run/nginx.pid \
        --lock-path=/opt/app/nginx/var/run/nginx.lock \
        --http-client-body-temp-path=/opt/app/nginx/cache/client_temp \
        --http-proxy-temp-path=/opt/app/nginx/cache/proxy_temp \
        --http-fastcgi-temp-path=/opt/app/nginx/cache/fastcgi_temp \
        --http-uwsgi-temp-path=/opt/app/nginx/cache/uwsgi_temp \
        --http-scgi-temp-path=/opt/app/nginx/cache/scgi_temp \
        --user=httpd \
        --group=httpd \
        --with-http_addition_module \
        --with-http_ssl_module \
        --with-http_realip_module \
        --with-http_sub_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_random_index_module \
        --with-http_secure_link_module \
        --with-http_stub_status_module \
        --with-http_auth_request_module \
        --with-http_xslt_module=dynamic \
        --with-http_slice_module \
        --with-http_v2_module \
        --with-stream \
        --with-stream_ssl_module \
        --with-http_image_filter_module=dynamic \
        --with-http_geoip_module=dynamic \
        --with-threads \
        --with-stream_ssl_preread_module \
        --with-stream_realip_module \
        --with-stream_geoip_module=dynamic \
        --with-mail \
        --with-mail_ssl_module \
        --with-compat \
        --with-file-aio \
        --with-debug \
        --with-ld-opt='-Wl,-rpath,/usr/local/lib' \
        --add-module=/opt/src/openresty-1.15.8.3/bundle/ngx_devel_kit-0.3.1rc1 \
        --add-module=/opt/src/openresty-1.15.8.3/bundle/xss-nginx-module-0.06 \
        --add-module=/opt/src/openresty-1.15.8.3/bundle/echo-nginx-module-0.61 \
        --add-module=/opt/src/openresty-1.15.8.3/bundle/set-misc-nginx-module-0.32 \
        --add-module=/opt/src/openresty-1.15.8.3/bundle/encrypted-session-nginx-module-0.08 \
        --add-module=/opt/src/openresty-1.15.8.3/bundle/srcache-nginx-module-0.31 \
        --add-module=/opt/src/openresty-1.15.8.3/bundle/memc-nginx-module-0.19 \
        --add-module=/opt/src/openresty-1.15.8.3/bundle/array-var-nginx-module-0.05 \
        --add-module=/opt/src/openresty-1.15.8.3/bundle/headers-more-nginx-module-0.33 \
        --add-module=/opt/src/openresty-1.15.8.3/bundle/redis-nginx-module-0.3.7 \
        --add-module=/opt/src/openresty-1.15.8.3/bundle/rds-json-nginx-module-0.15 \
        --add-module=/opt/src/openresty-1.15.8.3/bundle/rds-csv-nginx-module-0.09 \
#        --add-module=/opt/src/openresty-1.15.8.3/bundle/ngx_lua_upstream-0.07 \
#        --add-module=/opt/src/openresty-1.15.8.3/bundle/ngx_lua-0.10.15 \
        --add-module=/opt/src/openresty-1.15.8.3/bundle/iconv-nginx-module-0.14 \
        --add-module=/opt/src/openresty-1.15.8.3/bundle/ngx_coolkit-0.2 \
        --add-module=/opt/src/openresty-1.15.8.3/bundle/form-input-nginx-module-0.12 \
    " \
    GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8; \
    export GNUPGHOME="$(mktemp -d)"; \
    found=''; \
    for server in \
        ha.pool.sks-keyservers.net \
        hkp://keyserver.ubuntu.com:80 \
        hkp://p80.pool.sks-keyservers.net:80 \
        pgp.mit.edu \
    ; do \
        echo "Fetching GPG key $GPG_KEYS from $server"; \
        gpg --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$GPG_KEYS" && found=yes && break; \
    done; \
    test -z "$found" && echo >&2 "error: failed to fetch GPG key $GPG_KEYS" && exit 1; \
    gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz; \
    rm -r "$GNUPGHOME" nginx.tar.gz.asc; \
    tar -zxC /opt/src -f openresty.1.15.8.3.tar.gz; \
    tar -zxC /opt/src -f nginx.tar.gz; \
    rm *.tar.gz; \
    cd /opt/src/nginx-$NGINX_VERSION; \
    ./configure $CONFIG; \
    make install; \
    strip /opt/app/nginx/sbin/nginx*; \
    strip /opt/app/nginx/modules/*.so; \
    rm -rf /opt/src/nginx-$NGINX_VERSION; \
    \
    # Bring in gettext so we can get `envsubst`, then throw
    # the rest away. To do this, we need to install `gettext`
    # then move `envsubst` out of the way so `gettext` can
    # be deleted completely, then move `envsubst` back.
    apk add --no-cache --virtual .gettext gettext; \
    mv /usr/bin/envsubst /tmp/; \
    \
    runDeps="$( \
        scanelf --needed --nobanner /opt/app/nginx/sbin/nginx /opt/app/nginx/modules/*.so /tmp/envsubst \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )"; \
    apk add --no-cache --virtual .nginx-rundeps $runDeps; \
    apk del .build-deps; \
    apk del .gettext; \
    mv /tmp/envsubst /usr/local/bin/;

COPY conf/nginx.conf /opt/app/nginx/conf/nginx.conf
COPY conf/conf.d/*.conf /opt/app/nginx/conf/conf.d/
COPY conf/proxy.lua /opt/app/nginx/conf/proxy.lua
COPY conf/redis-cli /opt/app/nginx/conf/redis-cli
RUN chmod 777 /opt/app/nginx/conf/redis-cli; \
    chmod -R 777 /opt/app/nginx/conf/proxy.lua; \
    chmod -R 777 /opt/logs/nginx/;

COPY conf/cert/* /opt/app/nginx/conf/cert/

WORKDIR /opt/case

EXPOSE 80 443

STOPSIGNAL SIGTERM

CMD ["/opt/app/nginx/sbin/nginx", "-g", "daemon off;"]