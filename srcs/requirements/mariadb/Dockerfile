FROM debian:bullseye 
RUN apt update && apt upgrade -y && apt install -y mariadb-server
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/.
RUN mkdir /run/mysqld
ENTRYPOINT ["mysqld_safe"]