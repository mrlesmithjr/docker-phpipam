FROM debian:jessie

MAINTAINER Larry Smith Jr. <mrlesmithjr@gmail.com>

# Update apt-cache and install Apache
RUN apt-get update && \
    apt-get -y install apache2 libapache2-mod-php5 mysql-client php5-mysql php5-gmp php5-ldap php-pear unzip && \
    apt-get -y clean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -rf /var/www/html

# Download and extract phpIPAM
ADD https://github.com/phpipam/phpipam/archive/master.zip /tmp
RUN unzip /tmp/master.zip -d /var/www
RUN mv /var/www/phpipam-master /var/www/html

# Copy default site
COPY 000-default.conf /etc/apache2/sites-available/default

# Copy phpIPAM configuration
COPY config.php /var/www/html

RUN a2enmod rewrite

# Apache environment vars
ENV APACHE_LOCK_DIR /var/lock
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2/
ENV APACHE_PID_FILE /var/apache.pid

# phpIPAM Defaults
ENV SSL_ENABLED false
ENV PROXY_ENABLED false

# Expose port(s)
EXPOSE 80 443

ENTRYPOINT ["apache2ctl"]

CMD ["-D", "FOREGROUND"]
