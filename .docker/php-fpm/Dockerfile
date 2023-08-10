FROM php:8.2-fpm

WORKDIR "/application"
ARG XDEBUG_VERSION=3.2
ARG WITH_XDEBUG='n'

# Composer install
COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN apt-get update  \
   && apt-get upgrade -y \
   && apt-get install -y git libzip-dev unzip libpq5 libpq-dev wget libicu-dev \
   && docker-php-ext-install zip

# Calendar extension
RUN docker-php-ext-install calendar

# Imagick extension needed for webp
RUN apt-get install -y libmagickwand-dev; \
    pecl install imagick; \
    docker-php-ext-enable imagick;

# GD extension needed for html2pdf
RUN docker-php-ext-configure gd \
                --prefix=/usr \
                --with-jpeg \
                --with-webp \
                --with-xpm \
                --with-freetype; \
    docker-php-ext-install gd;


# XDebug extension
RUN if [ "$WITH_XDEBUG" = 'Y' ]; \
    then pecl install xdebug-${XDEBUG_VERSION} docker-php-ext-enable xdebug; fi

# Intl extension
RUN apt-get install libicu-dev
RUN docker-php-ext-configure intl && docker-php-ext-install intl

# Mysql extension
RUN docker-php-ext-install pdo_mysql

# Manage user
RUN useradd thelia -m \
&& usermod -a -G thelia thelia \
&& mkdir -p /application \
&& chown -R thelia:thelia /application


# Add default dir filesystem
RUN  mkdir /rootFs \
    && chown -R thelia:thelia /rootFs \
    && chmod 700 /rootFs

COPY ./php.ini /usr/local/etc/php/php.ini
COPY ./php-cli.ini /usr/local/etc/php/php-cli.ini

USER thelia

