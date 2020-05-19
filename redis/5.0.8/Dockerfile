FROM centos:8

LABEL MAINTAINER="丁明春"

ENV INSTALL_DIR /opt/app/redis

RUN yum -y install gcc gcc-c++ make \
    && yum clean all -y

# Timezone
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone

# Redis
ADD http://download.redis.io/releases/redis-5.0.8.tar.gz /tmp/
 
RUN cd /tmp && tar -xvf redis-5.0.8.tar.gz &&cd /tmp/redis-5.0.8 \
    && mkdir -p ${INSTALL_DIR}/{etc,var,logs,db} \
    && mkdir -p ${INSTALL_DIR}/var/log/ \
    && mkdir -p ${INSTALL_DIR}/var/lib/redis/6379 \
    && make && make install PREFIX=${INSTALL_DIR} \
    && rm -r /tmp/redis-5.0.8 && rm -rf redis-5.0.8.tar.gz
ADD etc/redis.conf ${INSTALL_DIR}/etc/redis.conf
# workdir
WORKDIR ${INSTALL_DIR}

EXPOSE 6379

CMD ["/opt/app/redis/bin/redis-server","/opt/app/redis/etc/redis.conf"]