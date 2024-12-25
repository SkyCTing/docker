ARG PHP_VERSION=php:8.3.15-fpm-alpine
FROM ${PHP_VERSION}

ARG TZ
ARG PHP_EXTENSIONS
ARG CONTAINER_PACKAGE_URL=mirrors.ustc.edu.cn


RUN if [ "${CONTAINER_PACKAGE_URL}" != "" ] ; then sed -i "s/dl-cdn.alpinelinux.org/${CONTAINER_PACKAGE_URL}/g" /etc/apk/repositories ; fi

COPY ./extensions /tmp/extensions
WORKDIR /tmp/extensions
RUN chmod +x install.sh \
    && sh install.sh \
    && rm -rf /tmp/extensions

ADD ./extensions/install-php-extensions  /usr/local/bin/
RUN chmod uga+x /usr/local/bin/install-php-extensions

RUN apk --no-cache add tzdata git shadow openssh gnu-libiconv libstdc++ \
    && cp "/usr/share/zoneinfo/$TZ" /etc/localtime \
    && echo "$TZ" > /etc/timezone \
    && usermod -u 1000 www-data \
    && groupmod -g 1000 www-data \
    && rm -rf /var/cache/apk/*


# Fix: https://github.com/docker-library/php/issues/240
ENV LD_PRELOAD="/usr/lib/preloadable_libiconv.so php"


# Install composer and change it's cache home
RUN curl -o /usr/bin/composer https://mirrors.aliyun.com/composer/composer.phar \
    && chmod +x /usr/bin/composer
ENV COMPOSER_HOME=/tmp/composer

# php image's www-data user uid & gid are 82, change them to 1000 (primary user)
RUN apk --no-cache add shadow && usermod -u 1000 www-data && groupmod -g 1000 www-data


WORKDIR /www
