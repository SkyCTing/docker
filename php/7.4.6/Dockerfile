FROM alpine:3.11

# set repositories
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

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
ENV INSTALL_DIR=/opt/app/php

RUN set -eux; \
    mkdir -p "$PHP_INI_DIR/conf.d"; \
    [ ! -d /opt/case ]; \
    mkdir -p /opt/case; \
    chown httpd:httpd /opt/case; \
    chmod 777 /opt/case

ENV PHP_EXTRA_CONFIGURE_ARGS --enable-fpm --with-fpm-user=httpd --with-fpm-group=httpd --disable-cgi

ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -pie"

ENV GPG_KEYS 42670A7FE4D0441C8E4632349E4FDC074A4EF02D 5A52880781F755608BF815FC910DEB46F53EA312

ENV PHP_VERSION 7.4.6
ENV PHP_URL="https://www.php.net/distributions/php-7.4.6.tar.xz" PHP_ASC_URL="https://www.php.net/distributions/php-7.4.6.tar.xz.asc"
ENV PHP_SHA256="d740322f84f63019622b9f369d64ea5ab676547d2bdcf12be77a5a4cffd06832" PHP_MD5=""

RUN set -eux; \
    \
    apk add --no-cache --virtual .fetch-deps gnupg; \
    \
    mkdir -p /opt/src; \
    cd /opt/src; \
    \
    curl -fsSL -o php.tar.xz "$PHP_URL"; \
    \
    if [ -n "$PHP_SHA256" ]; then \
        echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c -; \
    fi; \
    if [ -n "$PHP_MD5" ]; then \
        echo "$PHP_MD5 *php.tar.xz" | md5sum -c -; \
    fi; \
    \
    if [ -n "$PHP_ASC_URL" ]; then \
        curl -fsSL -o php.tar.xz.asc "$PHP_ASC_URL"; \
        export GNUPGHOME="$(mktemp -d)"; \
        for key in $GPG_KEYS; do \
            gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
        done; \
        gpg --batch --verify php.tar.xz.asc php.tar.xz; \
        gpgconf --kill all; \
        rm -rf "$GNUPGHOME"; \
    fi; \
    \
    apk del --no-network .fetch-deps

COPY docker-php-source /usr/local/bin/

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
    export CFLAGS="$PHP_CFLAGS" \
        CPPFLAGS="$PHP_CPPFLAGS" \
        LDFLAGS="$PHP_LDFLAGS"; \
    docker-php-source extract; \
    cd /opt/src/php; \
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    ./configure \
        --build="$gnuArch" \
        -prefix="$INSTALL_DIR" \
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
    /opt/app/php/bin/pecl update-channels; \
    rm -rf /tmp/pear ~/.pearrc; \
# smoke test
    /opt/app/php/bin/php --version

COPY docker-php-ext-* docker-php-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-php-entrypoint"]

WORKDIR /opt/case

RUN set -eux; \
    cd /opt/app/php/etc; \
    if [ -d php-fpm.d ]; then \
        # for some reason, upstream's php-fpm.conf.default has "include=NONE/etc/php-fpm.d/*.conf"
        sed 's!=NONE/!=!g' php-fpm.conf.default | tee php-fpm.conf > /dev/null; \
        cp php-fpm.d/www.conf.default php-fpm.d/web.conf; \
    else \
        # PHP 5.x doesn't use "include=" by default, so we'll create our own simple config that mimics PHP 7+ for consistency
        mkdir php-fpm.d; \
        cp php-fpm.conf.default php-fpm.d/www.conf; \
        { \
            echo '[global]'; \
            echo 'include=etc/php-fpm.d/*.conf'; \
        } | tee php-fpm.conf; \
    fi; \
    { \
        echo '[global]'; \
        echo 'error_log = /proc/self/fd/2'; \
        echo; echo '; https://github.com/docker-library/php/pull/725#issuecomment-443540114'; echo 'log_limit = 8192'; \
        echo; \
        echo '[web]'; \
        echo '; if we send this to /proc/self/fd/1, it never appears'; \
        echo 'access.log = /proc/self/fd/2'; \
        echo; \
        echo 'clear_env = no'; \
        echo; \
        echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
        echo 'catch_workers_output = yes'; \
        echo 'decorate_workers_output = no'; \
    } | tee php-fpm.d/docker.conf; \
    { \
        echo '[global]'; \
        echo 'daemonize = no'; \
        echo; \
        echo '[www]'; \
        echo 'listen = 9000'; \
    } | tee php-fpm.d/zz-docker.conf
COPY etc/web.conf "$PHP_INI_DIR/php-fpm.d/"
COPY etc/*.ini "$PHP_INI_DIR/"

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
    /opt/app/php/bin/pecl install redis; \
    docker-php-ext-enable redis; \
## Mongodb extension
    /opt/app/php/bin/pecl install mongodb; \
    docker-php-ext-enable mongodb; \
## Seaslog
    /opt/app/php/bin/pecl install seaslog; \
    docker-php-ext-enable seaslog; \
## apcu
    /opt/app/php/bin/pecl install apcu; \
    docker-php-ext-enable apcu; \
## xdebug
    /opt/app/php/bin/pecl install xdebug; \
    docker-php-ext-enable xdebug;\
    apk del --no-network .build-deps;

STOPSIGNAL SIGQUIT

EXPOSE 9000
CMD ["/opt/app/php/sbin/php-fpm"]