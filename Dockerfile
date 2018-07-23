FROM debian:jessie

MAINTAINER Larry Smith Jr. <mrlesmithjr@gmail.com>

ARG PHPIPAM_VERSION="1.3.2"

# Update apt-cache and install Apache
RUN apt-get update && \
    apt-get -y install apache2 cron libapache2-mod-php5 mysql-client \
    php5-curl php5-gd php5-gmp php5-ldap php5-mcrypt php5-mysql php5-snmp \
    php-pear unzip && \
    apt-get -y clean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -rf /var/www/html

# Install dumb-init
#ADD https://github.com/Yelp/dumb-init/releases/download/v1.1.2/dumb-init_1.1.2_amd64.deb /tmp
#RUN dpkg -i /tmp/dumb-init_1.1.2_amd64.deb

# Download and extract phpIPAM
ADD https://github.com/phpipam/phpipam/archive/phpipam-${PHPIPAM_VERSION}.zip /tmp
RUN unzip /tmp/phpipam-${PHPIPAM_VERSION}.zip -d /var/www
RUN mv /var/www/phpipam-${PHPIPAM_VERSION} /var/www/html

# Copy default site
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

# Copy phpIPAM configuration
COPY config.php /var/www/html

# Copy cron jobs
COPY phpipam_discoveryCheck /etc/cron.d
COPY phpipam_pingCheck /etc/cron.d
COPY phpipam_resolveIPaddresses /etc/cron.d

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
#CMD ['/usr/bin/dumb-init', '/usr/sbin/apache2ctl', '-D', 'FOREGROUND']
