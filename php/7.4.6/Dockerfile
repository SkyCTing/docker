FROM alpine:3.11

# set repositories
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

# dependencies required for running "phpize"
# these get automatically installed and removed by "docker-php-ext-*" (unless they're already installed)
ENV PHPIZE_DEPS \
        autoconf \
        dpkg-dev dpkg \
        file \
        g++ \
        gcc \
        libc-dev \
        make \
        pkgconf \
        re2c \
        libpng-dev \
        freetype-dev \
        libjpeg-turbo-dev \
        tidyhtml-dev \
        libzip-dev \
        gmp-dev

# persistent / runtime deps
RUN apk add --no-cache \
        ca-certificates \
        curl \
        tar \
        xz \
        openssl

# ensure httpd user exists
RUN set -eux; \
        addgroup -g 2000 -S httpd; \
        adduser -u 2000 -D -S -G httpd httpd

ENV PHP_INI_DIR /opt/app/php/etc
ENV INSTALL_DIR /opt/app/php

RUN set -eux; \
    mkdir -p "$PHP_INI_DIR/conf.d"; \
    mkdir -p /opt/case; \
    mkdir -p /opt/logs/php;\
    mkdir -p /opt/src; \
    mkdir -p /usr/local/sbin; \
    chown httpd:httpd /opt/case; \
    chown httpd:httpd /opt/logs/php; \
    chmod 777 /opt/case; \
    chmod 777 /opt/logs

ENV PHP_EXTRA_CONFIGURE_ARGS --enable-fpm --with-fpm-user=httpd --with-fpm-group=httpd --disable-cgi

ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -pie"

ENV PHP_VERSION 7.4.6
ENV PHP_URL="https://www.php.net/distributions/php-7.4.6.tar.xz"

COPY docker-php* /usr/local/bin/

RUN set -eux; \
    cd /opt/src; \
    curl -fsSL -o php.tar.xz "$PHP_URL"; \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        argon2-dev \
        coreutils \
        curl-dev \
        libedit-dev \
        libsodium-dev \
        libxml2-dev \
        linux-headers \
        oniguruma-dev \
        openssl-dev \
        sqlite-dev \
    ; \
    export CFLAGS="$PHP_CFLAGS" \
        CPPFLAGS="$PHP_CPPFLAGS" \
        LDFLAGS="$PHP_LDFLAGS"; \
    docker-php-source extract; \
    cd /opt/src/php; \
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    ./configure \
        --build="$gnuArch" \
        --prefix="$INSTALL_DIR" \
        --with-config-file-path="$PHP_INI_DIR" \
        --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
        --enable-option-checking=fatal \
        --enable-bcmath \
        --enable-dba \
        --enable-ftp \
        --enable-mbstring \
        --enable-sockets \
        --enable-exif \
        --enable-opcache \
        --enable-pcntl \
        --enable-soap \
        --enable-mysqlnd \
        --enable-xml \
        --enable-gd \
        --with-mhash \
        --with-password-argon2 \
        --with-sodium=shared \
        --with-pdo-sqlite \
        --with-sqlite3 \
        --with-curl \
        --with-libedit \
        --with-openssl \
        --with-zlib \
        --with-pear \
        --with-zip \
        --with-iconv \
        --with-gmp \
        --with-freetype \
        --with-jpeg \
        --with-tidy \
        --with-mysqli=mysqlnd \
        --with-pdo-mysql=mysqlnd \
        \
        $(test "$gnuArch" = 's390x-linux-musl' && echo '--without-pcre-jit') \
        \
        ${PHP_EXTRA_CONFIGURE_ARGS:-} \
    ; \
     make -j "$(nproc)"; \
    find -type f -name '*.a' -delete; \
    make install; \
    make clean; \
    cp -v php.ini-* "$PHP_INI_DIR/"; \
    cd /; \
    docker-php-source delete; \
    \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /opt/app/php \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /opt/app/php/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --no-cache $runDeps; \
    apk del --no-network .build-deps; \
    ln -s /opt/app/php/bin/* /usr/local/bin/; \
    ln -s /opt/app/php/sbin/php-fpm /usr/local/sbin/php-fpm; \
    pecl update-channels; \
    rm -rf /tmp/pear ~/.pearrc; \
# smoke test
    php --version

ENTRYPOINT ["docker-php-entrypoint"]

WORKDIR /opt/case

RUN set -eux; \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        argon2-dev \
        coreutils \
        curl-dev \
        libedit-dev \
        libsodium-dev \
        libxml2-dev \
        linux-headers \
        oniguruma-dev \
        openssl-dev \
        sqlite-dev \
    ; \
    docker-php-ext-enable sodium; \
## Redis extension
    pecl install redis; \
    docker-php-ext-enable redis; \
## Mongodb extension
    pecl install mongodb; \
    docker-php-ext-enable mongodb; \
## Seaslog
    pecl install seaslog; \
    docker-php-ext-enable seaslog; \
## apcu
    pecl install apcu; \
    docker-php-ext-enable apcu; \
## xdebug
    pecl install xdebug; \
    docker-php-ext-enable xdebug;\
    apk del --no-network .build-deps;

RUN apk add --virtual .timezone tzdata; \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
    echo "Asia/Shanghai" > /etc/timezone; \
    apk del --no-network .timezone;

RUN set -eux; \
    cd /opt/app/php/etc; \
    if [ -d php-fpm.d ]; then \
        sed 's!=NONE/!=!g' php-fpm.conf.default | tee php-fpm.conf > /dev/null; \
    else \
        # PHP 5.x doesn't use "include=" by default, so we'll create our own simple config that mimics PHP 7+ for consistency
        mkdir php-fpm.d; \
        { \
            echo '[global]'; \
            echo 'include=etc/php-fpm.d/*.conf'; \
        } | tee php-fpm.conf; \
    fi;

COPY etc/web.conf "$PHP_INI_DIR/php-fpm.d/"
COPY etc/*.ini "$PHP_INI_DIR/"

STOPSIGNAL SIGQUIT

EXPOSE 9000
CMD ["php-fpm", "-F"]