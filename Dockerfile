FROM php:5.5-apache

RUN buildDeps=" \
        libbz2-dev \
        libmysqlclient-dev \
        libc-client-dev \
        libkrb5-dev \
    " \
    runtimeDeps=" \
        curl \
        git \
        libfreetype6-dev \
        libicu-dev \
        libjpeg-dev \
        libpng12-dev \
        libpq-dev \
        libxml2-dev \
        openssh-client \
        rsync \
        wget \
    " \
    && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y $buildDeps $runtimeDeps \
    && docker-php-ext-install bcmath mysql mysqli soap zip gd \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap \
    && apt-get purge -y --auto-remove $buildDeps \
    && rm -r /var/lib/apt/lists/* \
    && a2enmod rewrite \
    && echo -e "log_errors = On\nerror_log = /dev/stderr\nerror_reporting = E_ALL & ~E_NOTICE" >> /usr/local/etc/php/conf.d/php.ini

RUN wget --no-check-certificate https://curl.se/ca/cacert.pem -O /etc/ssl/certs/cacert.pem

# Install Composer.
RUN curl --insecure -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --cafile=/etc/ssl/certs/cacert.pem \
    && ln -s $(composer config --global home) /root/composer
ENV PATH=$PATH:/root/composer/vendor/bin COMPOSER_ALLOW_SUPERUSER=1 
