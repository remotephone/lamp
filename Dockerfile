FROM ubuntu:trusty
MAINTAINER jaime 

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
  apt-get -y install supervisor git apache2 libapache2-mod-php5 mysql-server php5-mysql pwgen php-apc php5-mcrypt php5-gd && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Add image configuration and scripts
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

# config to enable .htaccess
#ADD apache_default /etc/apache2/sites-available/000-default.conf
#RUN a2enmod rewrite

# Install DVWA into your container
RUN rm -rf /app && git clone https://github.com/ethicalhack3r/DVWA.git /app
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html
RUN chmod 666 /app/hackable/uploads/
RUN chmod 666 /app/external/phpids/0.6/lib/IDS/tmp/phpids_log.txt

#fix DVWA php.ini to allow for RFI

RUN sed -i 's/allow_url_include = Off/allow_url_include = On/g' /etc/php5/apache2/php.ini

#Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add volumes for MySQL 
VOLUME  ["/etc/mysql", "/var/lib/mysql" ]

EXPOSE 80 3306
CMD ["/run.sh"]
