#!/bin/bash

docker login --username=mcskyding@vip.qq.com registry.cn-hangzhou.aliyuncs.com

docker network create --subnet=172.20.0.1/24 sky

mkdir -p ~/Develop/php/etc
cp php/7.4.8/etc/*.ini ~/Develop/php/etc

mkdir -p ~/Develop/nginx/conf/ssl
cp nginx/1.19.1/conf/ssl/*.* ~/Develop/nginx/conf/ssl

mkdir ~/Develop/nginx/conf/conf.d
cp nginx/1.19.1/conf/conf.d/*.conf ~/Develop/nginx/conf/conf.d

cp nginx/1.19.1/conf/nginx.conf ~/Develop/nginx/conf/nginx.conf

mkdir -p ~/Develop/logs/nginx
mkdir -p ~/Develop/logs/php

cp docker-compose.mac.yml docker-compose.yml

docker-compose up -d
