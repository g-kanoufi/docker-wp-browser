FROM php:7.2-apache-stretch

SHELL [ "/bin/bash", "-c" ]

# Install required system packages
RUN apt-get update && \
    apt-get -y install \
    # WordPress dependencies
    libjpeg-dev \
    libpng-dev \
    mysql-client \
    # CircleCI depedencies
    git \
    ssh \
    tar \
    gzip \
    wget

# Install php extensions
RUN docker-php-ext-install \
    bcmath \
    zip \
    gd \
    pdo_mysql \
    mysqli \
    opcache

# Configure php
RUN echo "date.timezone = UTC" >> /usr/local/etc/php/php.ini

# Install Dockerize
ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz


# Install composer
ENV COMPOSER_ALLOW_SUPERUSER=1

RUN curl -sS https://getcomposer.org/installer | php -- \
    --filename=composer \
    --install-dir=/usr/local/bin

# Install tool to speed up composer installations
RUN composer global require --optimize-autoloader \
    "hirak/prestissimo"

# Install wp-browser globally
RUN composer global require \
    phpunit/phpunit:8.1 \
    lucatume/wp-browser:^2.2 \
    fzaninotto/faker:^1.8

# Add composer global binaries to PATH
ENV PATH "$PATH:~/.composer/vendor/bin"

# Set up WordPress config
ENV WP_ROOT_FOLDER="/var/www/html"
ENV WP_URL="http://test.zrz"
ENV WP_DOMAIN="test.zrz"
ENV WP_TABLE_PREFIX="vnzokz0zw_"
ENV ADMIN_EMAIL="tester@test.zrz"
ENV ADMIN_USERNAME="admin"
ENV ADMIN_PASSWORD="password"

# Set up wp-browser / codeception
WORKDIR /var/www/config
COPY    config/codeception.dist.yml codeception.dist.yml

# Set up Apache
RUN  echo 'ServerName localhost' >> /etc/apache2/apache2.conf

# Set up entrypoint
WORKDIR    /var/www/html
COPY       entrypoint.sh /entrypoint.sh
RUN        chmod 755 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
