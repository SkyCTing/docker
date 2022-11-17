#### 使用前的操作

```shell
mkdir -p /opt/case
mkdir -p /opt/app/starnews/nginx
mkdir -p /opt/app/starnews/php
mkdir -p /opt/app/starnews/redis
mkdir -p /opt/app/starnews/mysql
```

开启环境:

```shell
docker-compose up -d
```

```shell
docker build --no-cache \
-t mcskyding/php:7.4.27 \
--build-arg PHP_VERSION=php:7.4.27-fpm-alpine \
--build-arg CONTAINER_PACKAGE_URL=mirrors.ustc.edu.cn \
--build-arg TZ=Asia/Shanghai \
--build-arg PHP_EXTENSIONS=pdo_mysql,mysqli,mbstring,gd,curl,opcache,zip,redis,soap,apcu,bcmath,dba,sockets,exif,pcntl,sodium,mongodb,xdebug \
.
```

阿里云镜像：https://cr.console.aliyun.com/cn-hangzhou/instance/repositories
$ sudo docker login --username=mcskyding@vip.qq.com registry.cn-hangzhou.aliyuncs.com


$ sudo docker login --username=mcskyding@vip.qq.com registry.cn-hangzhou.aliyuncs.com
$ sudo docker tag [ImageId] registry.cn-hangzhou.aliyuncs.com/skyting/docker:[镜像版本号]
$ sudo docker push registry.cn-hangzhou.aliyuncs.com/skyting/docker:[镜像版本号]


docker删除所有未使用的容器，删除所有未使用的镜像、网络
docker system prune -a -f  

docker删除所有未使用的镜像
docker image prune

docker删除所有未使用的容器（删除所有处于非运行状态的容器）
docker container prune

docker删除所有未使用的网络
docker network prune