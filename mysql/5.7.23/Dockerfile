FROM alpine:3.11

#ENV INSTALL_DIR /opt/app/mysql57
#
#ADD http://172.17.12.18/dist/mysql/gosu-amd64 /usr/bin/gosu
#
#RUN yum -y install epel-release \
#    && chmod +x /usr/bin/gosu
#
#RUN yum -y install zlib-devel openssl-devel libaio-devel \
#    git gcc gcc-c++ ncurses-devel bison cmake make \
#    && yum clean all -y
#
## Timezone
#RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
#    && echo 'Asia/Shanghai' > /etc/timezone

# Mysql
ADD http://172.17.12.18/dist/mysql/mysql-boost-5.7.23.tar.gz /tmp/
RUN cd /tmp && tar -xvf mysql-boost-5.7.23.tar.gz && cd /tmp/mysql-5.7.23 \
    && mkdir -p build \
    && cd build \
    && (cmake .. \
        -DBUILD_CONFIG=mysql_release \
        -DFEATURE_SET="community" \
        -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
        -DWITH_EMBEDDED_SERVER=off \
        -DINSTALL_SBINDIR=bin \
        -DINSTALL_SCRIPTDIR=bin \
        -DINSTALL_LIBDIR=lib/mysql \
        -DINSTALL_PLUGINDIR=lib/plugin \
        -DINSTALL_INCLUDEDIR=include \
        -DINSTALL_INFODIR=share/info \
        -DINSTALL_MANDIR=share/man \
        -DINSTALL_MYSQLSHAREDIR=share/mysql \
        -DINSTALL_SUPPORTFILESDIR=share/mysql \
        -DINSTALL_MYSQLTESTDIR=mysql-test \
        -DDEFAULT_CHARSET=utf8 \
        -DDEFAULT_COLLATION=utf8_general_ci \
        -DEXTRA_CHARSETS=all \
        -DENABLED_LOCAL_INFILE=ON \
        -DWITH_LIBEVENT=bundled \
        -DWITH_SSL=bundled \
        -DWITH_ZLIB=bundled \
        -DWITH_INNODB_MEMCACHED=on \
        -DWITH_BOOST=../boost \
        -DWITH_UNIT_TESTS=on \
        -DWITH_DEBUG=off \
    ) \
    && make -j4 \
    && make install 
RUN mkdir -p ${INSTALL_DIR}/var/ \
    && mkdir -p ${INSTALL_DIR}/tmp/ \
    && mkdir -p ${INSTALL_DIR}/logs/binlog/bin-log \
    && mkdir -p ${INSTALL_DIR}/logs/redolog/ \
    && mkdir -p ${INSTALL_DIR}/logs/undolog/ \
    && mkdir -p ${INSTALL_DIR}/etc/ \
    && mkdir -p ${INSTALL_DIR}/data/ \
    && groupadd -g 27 -o -r mysql \
    && useradd -M -g mysql -o -r -d /dev/null -s /sbin/nologin -u 27 mysql \
    && chown -R mysql:mysql ${INSTALL_DIR}/* \
    && rm -rf /tmp/mysql-5.7.23

ADD ../../services/mysql/5/my.cnf ${INSTALL_DIR}/etc/
RUN yum install -y openssl
# workdir
WORKDIR ${INSTALL_DIR}

COPY ./shell/docker-entrypoint.sh /usr/local/bin/
# backwards compat
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh \
    && chmod +x /usr/local/bin/docker-entrypoint.sh \
    && ln -s ${INSTALL_DIR}/bin/mysql* /usr/local/bin/ \
    && mkdir -p /docker-entrypoint-initdb.d/

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld"]