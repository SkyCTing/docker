#!/bin/bash

mkdir -p ~/Develop/php/etc
cp php/7.4.8/etc/*.ini ~/Develop/php/etc

mkdir -p ~/Develop/nginx/conf/ssl
cp nginx/1.19.1/conf/ssl/*.* ~/Develop/nginx/conf/ssl

mkdir ~/Develop/nginx/conf/conf.d
cp nginx/1.19.1/conf/conf.d/*.conf ~/Develop/nginx/conf/conf.d

cp nginx/1.19.1/conf/nginx.conf ~/Develop/nginx/conf/nginx.conf

mkdir ~/Develop/logs/nginx
mkdir ~/Develop/logs/php

docker-compose -f docker-compose.mac.yml up -d
