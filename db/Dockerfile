FROM mysql:9.1
LABEL maintainer="jeff@ressourcenkonflikt.de"

ENV MYSQL_DATABASE=mailserver \
    MYSQL_USER=mailserver \
    MYSQL_PASSWORD=aequ4Ayais \
    MYSQL_ROOT_PASSWORD=aequ4Ayais

COPY rootfs/ /
VOLUME /run/mysqld
