FROM debian:latest
MAINTAINER Adam Talsma <se-adam.talsma@ccpgames.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qqy \
&& apt-get install -qqy curl git expect bzip2 \
&& echo "deb http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list.d/dotdeb.list \
&& echo "deb-src http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list.d/dotdeb.list \
&& echo "deb http://repo.mysql.com/apt/debian/ jessie mysql-5.6" >> /etc/apt/sources.list.d/mysql.list \
&& echo "deb-src http://repo.mysql.com/apt/debian/ jessie mysql-5.6" >> /etc/apt/sources.list.d/mysql.list \
&& curl http://www.dotdeb.org/dotdeb.gpg | apt-key add - \
&& curl http://repo.mysql.com/RPM-GPG-KEY-mysql | apt-key add - \
&& apt-get update -qqy \
&& apt-get install -qqy php7.0 php7.0-cli php7.0-mcrypt php7.0-intl php7.0-mysql php7.0-curl php7.0-gd mysql-client-5.6 mysql-server-5.6

ARG MYSQL_DUMP_HOST=https://www.fuzzwork.co.uk/dump
ARG GIT_BRANCH=master
RUN curl -L $MYSQL_DUMP_HOST/mysql-latest.tar.bz2 > /tmp/mysql-latest.tar.bz2 \
&& rm -rf /var/www/html \
&& git clone -b $GIT_BRANCH --single-branch https://github.com/exodus4d/pathfinder.git /var/www/html \
&& chown -R www-data:www-data /var/www/html

COPY start_mysql.sh /usr/local/bin/
COPY seed_ccp_data.sh /tmp/seed_ccp_data.sh
RUN /tmp/seed_ccp_data.sh && rm -rf /tmp/*

EXPOSE 80
WORKDIR /var/www/html

COPY entrypoint.sh /
CMD /entrypoint.sh
