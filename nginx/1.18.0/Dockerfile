FROM nginx:1.18-alpine
COPY conf/conf.d /opt/app/nginx/conf/sites/starnews.conf
COPY conf/nginx.conf /opt/app/nginx/conf/nginx.conf
COPY conf/proxy.lua /opt/app/nginx/conf/proxy.lua
COPY conf/redis-cli /opt/app/nginx/conf/redis-cli
RUN chmod 777 /opt/app/nginx/conf/redis-cli && \
    chmod -R 777 /opt/app/nginx/conf/proxy.lua && \
    mkdir -p /opt/app/nginx/logs/ && \
    chmod -R 777 /opt/app/nginx/logs/


COPY conf /opt/app/nginx/conf/sites/starnews.conf
COPY conf /opt/app/nginx/conf/nginx.conf
RUN mkdir -p /opt/app/nginx/conf/ssl
COPY ssl /opt/app/nginx/conf/ssl/starnews.crt
COPY ssl /opt/app/nginx/conf/ssl/starnews.key