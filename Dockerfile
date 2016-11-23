FROM lnxtm/docker-cron

MAINTAINER Alexander Shevchenko <kudato@me.com>
# env
ENV EMAIL mailbox@example.com
ENV LETSENCRYPT true

ENV REPO external
ENV BRANCH master

ENV GIT_USER nosetuser
ENV GIT_PASS nosetpass

ENV HTTP 80
ENV HTTPS 443

ENV FQDN example.com
ENV WWW_FQDN www.example.com

ENV PHP_MEMORY 256MB
ENV PHP_PM_MAX 10
ENV PHP_PM_START 2
ENV PHP_PM_SPARE_MIN 2
ENV PHP_PM_SPARE_MAX 4

ENV POST_MAX_SIZE 8192
ENV PHP_DISPLAY_ERROR Off
ENV PHP_SHORT_OPEN_TAG Off

# letsencrypt
RUN apt-get install -y letsencrypt
ADD le.sh /le.sh
ADD localhost /localhost

# nginx
RUN apt-get install -y nginx && \
	echo "[program:nginx]" >> /etc/supervisor/conf.d/supervisord.conf && \
	echo "command = /usr/sbin/nginx" >> /etc/supervisor/conf.d/supervisord.conf && \
	echo "autostart = true" >> /etc/supervisor/conf.d/supervisord.conf && \
	rm -rf /etc/nginx/sites-enabled/* && mkdir -p /usr/share/nginx/html
ADD nginx.conf /etc/nginx/
ADD http /etc/nginx/sites-enabled/http
ADD https /https

# php
RUN apt-get install -y php7.0-fpm php7.0-common php7.0-cli php-apcu \
	php-redis php-mbstring php7.0-mysql php7.0-curl php7.0-gd php7.0-intl \
	php-pear imagemagick php7.0-imagick php-imagick php7.0-imap php7.0-mcrypt \
	php7.0-pspell php7.0-recode php-patchwork-utf8 php7.0-json libxml-rss-perl \
	zlib1g php7.0-ldap php7.0-sqlite php7.0-tidy php7.0-xmlrpc php7.0-xsl \
	php7.0-zip php-iconv php7.0-iconv && \
	echo "[program:php-fpm7.0]" >> /etc/supervisor/conf.d/supervisord.conf && \
	echo "command = /usr/sbin/php-fpm7.0" >> /etc/supervisor/conf.d/supervisord.conf && \
	echo "autostart = true" >> /etc/supervisor/conf.d/supervisord.conf && \
	rm -rf /etc/php
ADD php /etc/php

# mysql support
RUN apt-get install -y mysql-client libmysqlclient-dev
# samba shares support
RUN apt-get install -y smbclient
# LibreOffice for preview
RUN apt-get -y install --no-install-recommends libreoffice

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chmod +x /le.sh && \
	mkdir /etc/nginx/ssl
ADD pupu.sh /pupu.sh
RUN chmod +x /pupu.sh && apt-get clean
###########################################################################
CMD ["/entrypoint.sh"]