docker login --username=mcskyding@vip.qq.com registry.cn-hangzhou.aliyuncs.com

docker network create --subnet=172.20.0.1/24 sky

mkdir D:\Develop\php\etc
copy php\7.4.8\etc\*.ini D:\Develop\php\etc

mkdir D:\Develop\nginx\conf\cert
copy nginx\1.19.1\conf\cert\*.* D:\Develop\nginx\conf\cert

mkdir D:\Develop\nginx\conf\conf.d
copy nginx\1.19.1\conf\conf.d\*.conf D:\Develop\nginx\conf\conf.d

copy nginx\1.19.1\conf\nginx.conf D:\Develop\nginx\conf\nginx.conf

copy docker-compose.mac.yml docker-compose.yml
docker-compose up -d

