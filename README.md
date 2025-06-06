
update @ 2023-12-20

默认使用image标签，出现不兼容时，注释image配置，使用build

DNMP（Docker + Nginx/Openresty + MySQL5,8 + PHP5,7,8 + Redis + ElasticSearch + MongoDB + RabbitMQ）是一款全功能的***\*LNMP一键安装程序，支持Arm CPU\****。

<details>
<summary>DNMP项目特点</summary>

1. `100%`开源

2. `100%`遵循Docker标准

3. 支持**多版本PHP**共存，可任意切换（PHP5.4、PHP5.6、PHP7.1、PHP7.2、PHP7.3、PHP7.4、PHP8.0)

4. 支持绑定**任意多个域名**

5. 支持**HTTPS和HTTP/2**

6. **PHP源代码、MySQL数据、配置文件、日志文件**都可在Host中直接修改查看

7. 内置**完整PHP扩展安装**命令

8. 默认支持`pdo_mysql`、`mysqli`、`mbstring`、`gd`、`curl`、`opcache`等常用热门扩展，根据环境灵活配置

9. 可一键选配常用服务：
    - 多PHP版本：PHP5.4、PHP5.6、PHP7.0-7.4、PHP8.0
    - Web服务：Nginx、Openresty
    - 数据库：MySQL5、MySQL8、Redis、memcached、MongoDB、ElasticSearch
    - 消息队列：RabbitMQ
    - 辅助工具：Kibana、Logstash、phpMyAdmin、phpRedisAdmin、AdminMongo

10. 实际项目中应用，确保`100%`可用

11. 所有镜像源于[Docker官方仓库](https://hub.docker.com)，安全可靠

12. 一次配置，**Windows、Linux、MacOs**皆可用

13. 支持快速安装扩展命令 `install-php-extensions apcu`

14. 支持安装certbot获取免费https用的SSL证书
    </details>
     [TOC]

## 1. 目录结构

```
/
├── data                        数据库数据目录
│   ├── composer                composer 数据目录
│   ├── esdata                  ElasticSearch 数据目录
│   ├── mongo                   MongoDB 数据目录
│   ├── mysql                   MySQL8 数据目录
│   ├── mysql5                  MySQL5 数据目录
│   └── redis                   Redis 数据目录
├── services                    服务构建文件和配置文件目录
│   ├── elasticsearch           ElasticSearch 配置文件目录
│   ├── mysql                   MySQL8 配置文件目录
│   ├── mysql5                  MySQL5 配置文件目录
│   ├── nginx                   Nginx 配置文件目录
│   ├── php                     PHP5.6 - PHP7.4 配置目录
│   ├── php54                   PHP5.4 配置目录
│   └── redis                   Redis 配置目录
├── logs                        日志目录
├── docker-compose.sample.yml   Docker 服务配置示例文件
├── docker-compose.yml   				Docker 服务配置文件
├── env.smaple                  环境配置示例文件
├── LICENSE											证书
├── README.md										说明文件
└── www                         PHP 代码目录

```

## 2. 快速使用

1. 本地安装

- `git`
- `Docker`(系统需为Linux，Windows 10 Build 15063+，或MacOS 10.12+，且必须要`64`位）
- `docker-compose 1.7.0+`

2. clone 项目：

```shell
$ git clone git@github.com:SkyCTing/docker.git
```

3. 如果主机是 Linux系统，且当前用户不是root用户，还需将当前用户加入docker用户组：

```shell
$ sudo gpasswd -a ${USER} docker
```

4. 拷贝并命名配置文件（Windows系统请用copy命令），启动：

```shell
$ cd docker                                         # 进入项目目录
$ cp env.sample .env                                # 复制环境变量文件
$ cp docker-compose.sample.yml docker-compose.yml   # 复制 docker-compose 配置文件。默认启动3
                                                    # 个服务：Nginx、PHP7和MySQL8。要开启更多
                                                    # 其他服务，如Redis、PHP5.6、PHP5.4、	
                                                    # MongoDB，ElasticSearch等，请删
                                                    # 除服务块前的注释
$ docker-compose up -d                              # 启动
```
5. 复制主机git文件,安装ssh
```shell
docker cp ~/.ssh php82:/root/
apk add git
apk add openssh-client
```
6. 在浏览器中访问：`http://localhost`或`https://localhost就能看到效果，PHP代码在文件`./www/localhost/index.php`。

## 3. PHP和扩展

### 3.1 切换Nginx使用的PHP版本
首先，需要启动其他版本的PHP，比如PHP5.4，那就先在`docker-compose.yml`文件中删除PHP5.4前面的注释，再启动PHP5.4容器。

PHP5.4启动后，打开Nginx 配置，修改`fastcgi_pass`的主机地址，由`php`改为`php54`，如下：
```
    fastcgi_pass   php:9000;
```
为：
```
    fastcgi_pass   php54:9000;
```
其中 `php` 和 `php54` 是`docker-compose.yml`文件中服务器的名称。

最后，**重启 Nginx** 生效。
```bash
$ docker exec -it nginx nginx -s reload
```
这里两个`nginx`，第一个是容器名，第二个是容器中的`nginx`程序。


### 3.2 安装PHP扩展
PHP的很多功能都是通过扩展实现，而安装扩展是一个略费时间的过程，
所以，除PHP内置扩展外，在`env.sample`文件中我们仅默认安装少量扩展，
如果要安装更多扩展，请打开你的`.env`文件修改如下的PHP配置，
增加需要的PHP扩展：
```bash
PHP_EXTENSIONS=pdo_mysql,opcache,redis       # PHP 要安装的扩展列表，英文逗号隔开
PHP54_EXTENSIONS=opcache,redis                 # PHP 5.4要安装的扩展列表，英文逗号隔开
```
然后重新build PHP镜像。
```bash
docker-compose build php
```
可用的扩展请看同文件的`env.sample`注释块说明。

### 3.3 快速安装php扩展
1.进入容器:

```sh
docker exec -it php /bin/sh

install-php-extensions apcu 
```
2.支持快速安装扩展列表

| Extension | PHP 5.5 | PHP 5.6 | PHP 7.0 | PHP 7.1 | PHP 7.2 | PHP 7.3 | PHP 7.4 | PHP 8.0 | PHP 8.1 | PHP 8.2 |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| amqp | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| apcu | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| apcu_bc |  |  | &check; | &check; | &check; | &check; | &check; |  |  |  |
| ast |  |  | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| bcmath | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| bitset | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| blackfire | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| bz2 | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| calendar | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| cassandra[*](#special-requirements-for-cassandra) |  |  |  |  | &check; | &check; | &check; | &check; | &check; | &check; |
| cmark |  |  | &check; | &check; | &check; | &check; | &check; |  |  |  |
| csv |  |  |  |  |  | &check; | &check; | &check; | &check; | &check; |
| dba | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| ddtrace[*](#special-requirements-for-ddtrace) |  | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| decimal |  |  | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| ds |  |  | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| ecma_intl[*](#special-requirements-for-ecma_intl) |  |  |  |  |  |  |  |  |  | &check; |
| enchant | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| ev | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| event | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| excimer |  |  |  | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| exif | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| ffi |  |  |  |  |  |  | &check; | &check; | &check; | &check; |
| gd | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| gearman | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |  |  |
| geoip | &check; | &check; | &check; | &check; | &check; | &check; | &check; |  |  |  |
| geos[*](#special-requirements-for-geos) | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| geospatial | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| gettext | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| gmagick | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| gmp | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| gnupg | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| grpc | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| http | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| igbinary | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| imagick | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| imap | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| inotify | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| interbase | &check; | &check; | &check; | &check; | &check; | &check; |  |  |  |  |
| intl | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| ion |  |  |  |  |  |  |  |  | &check; | &check; |
| ioncube_loader | &check; | &check; | &check; | &check; | &check; | &check; | &check; |  | &check; |  |
| jsmin | &check; | &check; | &check; | &check; | &check; | &check; | &check; |  |  |  |
| json_post | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| jsonpath |  |  |  |  |  |  | &check; | &check; | &check; | &check; |
| ldap | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| luasandbox | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| lz4[*](#special-requirements-for-lz4) |  | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| lzf | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| mailparse | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| maxminddb |  |  |  |  | &check; | &check; | &check; | &check; | &check; | &check; |
| mcrypt | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| memcache | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| memcached[*](#special-requirements-for-memcached) | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| memprof[*](#special-requirements-for-memprof) | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| mongo | &check; | &check; |  |  |  |  |  |  |  |  |
| mongodb | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| mosquitto | &check; | &check; | &check; | &check; | &check; | &check; | &check; |  |  |  |
| msgpack | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| mssql | &check; | &check; |  |  |  |  |  |  |  |  |
| mysql | &check; | &check; |  |  |  |  |  |  |  |  |
| mysqli | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| oauth | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| oci8 | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| odbc | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| opcache | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| opencensus |  |  | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| openswoole |  |  |  |  | &check; | &check; | &check; | &check; | &check; | &check; |
| opentelemetry |  |  |  |  |  |  |  | &check; | &check; | &check; |
| parallel[*](#special-requirements-for-parallel) |  |  |  | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| parle[*](#special-requirements-for-parle) |  |  | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| pcntl | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| pcov |  |  | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| pdo_dblib | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| pdo_firebird | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| pdo_mysql | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| pdo_oci |  |  | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| pdo_odbc | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| pdo_pgsql | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| pdo_sqlsrv[*](#special-requirements-for-pdo_sqlsrv) |  |  | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| pgsql | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| php_trie |  |  |  |  |  | &check; | &check; | &check; | &check; | &check; |
| pkcs11 |  |  |  |  |  |  | &check; | &check; | &check; | &check; |
| pq |  |  | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| propro | &check; | &check; | &check; | &check; | &check; | &check; | &check; |  |  |  |
| protobuf | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| pspell | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| pthreads[*](#special-requirements-for-pthreads) | &check; | &check; | &check; |  |  |  |  |  |  |  |
| raphf | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| rdkafka | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| recode | &check; | &check; | &check; | &check; | &check; | &check; |  |  |  |  |
| redis | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| relay |  |  |  |  |  |  | &check; | &check; | &check; | &check; |
| seasclick | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| seaslog | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| shmop | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| simdjson[*](#special-requirements-for-simdjson) |  |  |  | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| smbclient | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| snappy | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| snmp | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| snuffleupagus |  |  | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| soap | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| sockets | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| sodium[*](#special-requirements-for-sodium) |  | &check; | &check; | &check; |  |  |  |  |  |  |
| solr | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| sourceguardian | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| spx |  | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| sqlsrv[*](#special-requirements-for-sqlsrv) |  |  | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| ssh2 | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| stomp | &check; | &check; | &check; | &check; | &check; | &check; | &check; |  |  | &check; |
| swoole | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| sybase_ct | &check; | &check; |  |  |  |  |  |  |  |  |
| sync | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| sysvmsg | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| sysvsem | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| sysvshm | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| tensor[*](#special-requirements-for-tensor) |  |  |  |  | &check; | &check; | &check; | &check; |  |  |
| tideways | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| tidy | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| timezonedb | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| uopz | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| uploadprogress | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| uuid | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| uv |  |  |  |  |  |  |  | &check; | &check; | &check; |
| vips[*](#special-requirements-for-vips) |  |  | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| wddx | &check; | &check; | &check; | &check; | &check; | &check; |  |  |  |  |
| xdebug | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| xdiff | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| xhprof | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| xlswriter |  |  | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| xmldiff | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| xmlrpc | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| xsl | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| yac |  |  | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| yaml | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| yar | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |  |
| zephir_parser |  |  | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| zip | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| zmq | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| zookeeper | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| zstd | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |

*Number of supported extensions: 141*

此扩展来自[https://github.com/mlocati/docker-php-extension-installer](https://github.com/mlocati/docker-php-extension-installer)参考示例文件

### 3.4 Host中使用php命令行（php-cli）

1. 参考[bash.alias.sample](bash.alias.sample)示例文件，将对应 php cli 函数拷贝到主机的 `~/.bashrc`文件。
2. 让文件起效：
    ```bash
    source ~/.bashrc
    ```
3. 然后就可以在主机中执行php命令了：
    ```bash
    ~ php -v
    PHP 7.2.13 (cli) (built: Dec 21 2018 02:22:47) ( NTS )
    Copyright (c) 1997-2018 The PHP Group
    Zend Engine v3.2.0, Copyright (c) 1998-2018 Zend Technologies
        with Zend OPcache v7.2.13, Copyright (c) 1999-2018, by Zend Technologies
        with Xdebug v2.6.1, Copyright (c) 2002-2018, by Derick Rethans
    ```
### 3.5 使用composer
**方法1：主机中使用composer命令**
1. 确定composer缓存的路径。比如，我的dnmp下载在`~/dnmp`目录，那composer的缓存路径就是`~/dnmp/data/composer`。
2. 参考[bash.alias.sample](bash.alias.sample)示例文件，将对应 php composer 函数拷贝到主机的 `~/.bashrc`文件。
    > 这里需要注意的是，示例文件中的`~/dnmp/data/composer`目录需是第一步确定的目录。
3. 让文件起效：
    ```bash
    source ~/.bashrc
    ```
4. 在主机的任何目录下就能用composer了：
    ```bash
    cd ~/dnmp/www/
    composer create-project yeszao/fastphp project --no-dev
    ```
5. （可选）第一次使用 composer 会在 `~/dnmp/data/composer` 目录下生成一个**config.json**文件，可以在这个文件中指定国内仓库，例如：
    ```json
    {
        "config": {},
        "repositories": {
            "packagist": {
                "type": "composer",
                "url": "https://mirrors.aliyun.com/composer/"
            }
        }
    }
    
    ```

**方法2：容器内使用composer命令**

还有另外一种方式，就是进入容器，再执行`composer`命令，以PHP7容器为例：
```bash
docker exec -it php /bin/sh
cd /www/localhost
composer update
```

## 4. 创建代码用户

``` shell
$ adduser www-data
$ usermod -s /sbin/nologin www-data
```

## 5. 编译镜像

```shell
docker buildx create --use --name=sky
docker buildx inspect --bootstrap sky

docker buildx build --no-cache \
-t mcskyding/php:8.3.1 \
--platform linux/arm64,linux/amd64,linux/amd64/v2,linux/riscv64,linux/ppc64le,linux/s390x,linux/386,linux/arm/v7,linux/arm/v6 \
--build-arg PHP_VERSION=php:8.3.1-fpm-alpine \
--build-arg CONTAINER_PACKAGE_URL=mirrors.ustc.edu.cn \
--build-arg TZ=Asia/Shanghai \
--build-arg PHP_EXTENSIONS=pdo_mysql,mysqli,mbstring,gd,curl,opcache,zip,redis,soap,apcu,bcmath,dba,sockets,exif,pcntl,sodium,mongodb,xdebug,imap,msgpack \
. --push
```

## 6. 远端镜像

阿里云镜像：https://cr.console.aliyun.com/cn-hangzhou/instance/repositories

``` shell
$ docker login --username=mcskyding@vip.qq.com registry.cn-hangzhou.aliyuncs.com
$ docker tag [ImageId] registry.cn-hangzhou.aliyuncs.com/mcskyding/docker:[镜像版本号]
$ docker push registry.cn-hangzhou.aliyuncs.com/mcskyding/docker:[镜像版本号]
```

docker官方镜像：https://hub.docker.com/

```shell
$ docker login --username=mcskyding
$ docker tag [ImageId] mcskyding/docker:[镜像版本号]
$ docker push mcskyding/docker:[镜像版本号]
```



## 7. 管理命令

### 7.1 服务器启动和构建命令

``` shell
$ docker-compose up                         # 创建并且启动所有容器
$ docker-compose up -d                      # 创建并且后台运行方式启动所有容器
$ docker-compose up nginx php mysql         # 创建并且启动nginx、php、mysql的多个容器
$ docker-compose up -d nginx php  mysql     # 创建并且已后台运行的方式启动nginx、php、mysql容器

$ docker-compose start php                  # 启动服务
$ docker-compose stop php                   # 停止服务
$ docker-compose restart php                # 重启服务
$ docker-compose down --rmi all							# 停止并删除
$ docker-compose build php                  # 构建或者重新构建服务
$ docker-compose up -d --build php nginx 		# 修改dockerfile或者env文件之后rebuild可生效
$ docker-compose rm php                     # 删除并且停止php容器
$ docker-compose down                       # 停止并删除容器，网络，图像和挂载卷

$ docker system prune -a -f  								# 删除所有未使用的容器，删除所有未使用的镜像、网络
$ docker image prune												# 删除所有未使用的镜像
$ docker container prune										# 删除所有未使用的容器（删除所有处于非运行状态的容器）
$ docker network prune											# 删除所有未使用的网络
```

### 7.2 添加快捷命令
在开发的时候，我们可能经常使用`docker exec -it`进入到容器中，把常用的做成命令别名是个省事的方法。

首先，在主机中查看可用的容器：
```bash
$ docker ps           # 查看所有运行中的容器
$ docker ps -a        # 所有容器
```
输出的`NAMES`那一列就是容器的名称，如果使用默认配置，那么名称就是`nginx`、`php`、`php56`、`mysql`等。

然后，打开`~/.bashrc`或者`~/.zshrc`文件，加上：
```bash
alias dnginx='docker exec -it nginx /bin/sh'
alias dphp='docker exec -it php /bin/sh'
alias dphp56='docker exec -it php56 /bin/sh'
alias dphp54='docker exec -it php54 /bin/sh'
alias dmysql='docker exec -it mysql /bin/bash'
alias dredis='docker exec -it redis /bin/sh'
```
下次进入容器就非常快捷了，如进入php容器：
```bash
$ dphp
```

### 7.3 查看docker网络
```sh
ifconfig docker0
```
用于填写`extra_hosts`容器访问宿主机的`hosts`地址

## 8 测试NGINX

```
$ cp nginx/conf.d/default.conf.example nginx/conf.d/default.conf
$ docker-compose restart nginx

#绑定本机hosts
127.0.0.1 default.dev.com

```
访问 http://default.dev.com/ 得到响应 Hello Ogenes! 表示运行成功。

![QQ截图20210114105752.png](https://i.loli.net/2021/01/14/NPTJhEgcszFZaOp.png)

## 9 Certbot 申请ssl证书
1. 先配置http可访问， 以 coupon.pianophile.cn 为例

```shell
vim nginx/conf.d/coupon.conf
server {
    listen 80;
    listen [::]:80;

    server_name coupon.pianophile.cn;
    root  /www/coupon;    # 针对Laravel，需要定位到public

    location / {
        charset utf-8;
        default_type text/html;
        return 200 'Hello World!';
    }
}

docker exec -it nginx nginx -s reload
curl  coupon.pianophile.cn
```
2. 申请ssl证书

```shell
docker-compose run --rm  certbot certonly --preferred-challenges dns -d *.test.com -d test.com --cert-name test.com --manual
docker-compose run --rm  certbot certonly --webroot --webroot-path /www/coupon/ -d coupon.pianophile.cn --cert-name coupon
certbot certificates
certbot delete --cert-name example.com
```

| 参数                  | 解释                                                         |
| --------------------- | ------------------------------------------------------------ |
| certonly              | 创建时使用, 表示采用验证模式，只会获取证书                   |
| renew                 | 更新时使用                                                   |
| –manual               | 配置插件,http验证/dns验证                                    |
| –webroot              | http验证                                                     |
| –force-renewal        | 强制续签                                                     |
| –preferred-challenges | dnsdns验证, 表示采用DNS验证申请者合法性                      |
| –dry-run              | 测试执行,不会真正去申请                                      |
| –manual-auth-hook     | 动态验证DNS的脚本服务                                        |
| –deploy-hook          | 成功后指定执行命令，重启 nginx, 因为nginx不会自动加载证书，reload也不会 |
| -d *.xxx.com          | 域名(可以是通配符)                                           |
| -m xxx@xxx.com        | 通知邮箱                                                     |

3. 修改nginx配置，支持https

```shell
vim nginx/conf.d/coupon.conf
server {
    listen          80;
    listen          [::]:80;
    server_name     coupon.pianophile.cn;
    return          301	https://coupon.pianophile.cn$request_uri;
}

server {
    listen              443 ssl http2;
    listen              [::]:443 ssl http2;
    server_name         coupon.pianophile.cn;
    ssl_certificate     ssl/live/coupon/fullchain.pem;
    ssl_certificate_key ssl/live/coupon/privkey.pem;
    ssl_protocols       TLSv1.1 TLSv1.2 TLSv1.3;

    location / {
        charset utf-8;
        default_type text/html;
        return 200 'Hello World!';
    }
}
```

4. 配置计划任务，每个月月初自动刷新

```shell
0 0 0 * * cd /data/web/docker && docker-compose run --rm certbot renew >> /dev/null 2>&1
```

## 10 使用Log

Log文件生成的位置依赖于conf下各log配置的值。

### 10.1 Nginx日志
Nginx日志是我们用得最多的日志，所以我们单独放在根目录`log`下。

`log`会目录映射Nginx容器的`/var/log/nginx`目录，所以在Nginx配置文件中，需要输出log的位置，我们需要配置到`/var/log/nginx`目录，如：
```
error_log  /var/log/nginx/nginx.localhost.error.log  warn;
```


### 10.2 PHP-FPM日志
大部分情况下，PHP-FPM的日志都会输出到Nginx的日志中，所以不需要额外配置。

另外，建议直接在PHP中打开错误日志：
```php
error_reporting(E_ALL);
ini_set('error_reporting', 'on');
ini_set('display_errors', 'on');
```

如果确实需要，可按一下步骤开启（在容器中）。

1. 进入容器，创建日志文件并修改权限：
    ```bash
    $ docker exec -it php /bin/sh
    $ mkdir /var/log/php
    $ cd /var/log/php
    $ touch php-fpm.error.log
    $ chmod a+w php-fpm.error.log
    ```
2. 主机上打开并修改PHP-FPM的配置文件`conf/php-fpm.conf`，找到如下一行，删除注释，并改值为：
    ```
    php_admin_value[error_log] = /var/log/php/php-fpm.error.log
    ```
3. 重启PHP-FPM容器。

### 10.3 MySQL日志
因为MySQL容器中的MySQL使用的是`mysql`用户启动，它无法自行在`/var/log`下的增加日志文件。所以，我们把MySQL的日志放在与data一样的目录，即项目的`mysql`目录下，对应容器中的`/var/log/mysql/`目录。
```bash
slow-query-log-file     = /var/log/mysql/mysql.slow.log
log-error               = /var/log/mysql/mysql.error.log
```
以上是mysql.conf中的日志文件的配置。



## 11 数据库管理
本项目默认在`docker-compose.yml`中不开启了用于MySQL在线管理的*phpMyAdmin*，以及用于redis在线管理的*phpRedisAdmin*，可以根据需要修改或删除。

### 11.1 phpMyAdmin
phpMyAdmin容器映射到主机的端口地址是：`8080`，所以主机上访问phpMyAdmin的地址是：
```
http://localhost:8080
```

MySQL连接信息：
- host：(本项目的MySQL容器网络)
- port：`3306`
- username：（手动在phpmyadmin界面输入）
- password：（手动在phpmyadmin界面输入）

### 11.2 phpRedisAdmin
phpRedisAdmin容器映射到主机的端口地址是：`8081`，所以主机上访问phpMyAdmin的地址是：
```
http://localhost:8081
```

Redis连接信息如下：
- host: (本项目的Redis容器网络)
- port: `6379`


## 12. 在正式环境中安全使用
要在正式环境中使用，请：
1. 在php.ini中关闭XDebug调试
2. 增强MySQL数据库访问的安全策略
3. 增强redis访问的安全策略

## 13. 帮助

1. git重置到第一次提交 git reset --soft $(git rev-list --max-parents=0 HEAD)
2. 新建空白分支git checkout --orphan new-branch  && git rm -rf .
