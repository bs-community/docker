FROM composer:latest as vendor
WORKDIR /app
COPY source/composer.json source/composer.lock ./
ARG GITHUB_TOKEN="t"
RUN if [ ${GITHUB_TOKEN} != "t" ]; then \
    composer config -g github-oauth.github.com ${GITHUB_TOKEN} && \
    composer global require hirak/prestissimo \
;fi
RUN composer i \
    --prefer-dist \
    --no-dev \
    --no-suggest \
    --no-progress \
    --no-autoloader \
    --no-scripts \
    --no-interaction \
    --ignore-platform-reqs

FROM node:12-alpine AS build
WORKDIR /app
COPY source/package.json source/yarn.lock ./
RUN yarn
COPY source/resources ./resources/
COPY source/postcss.config.js source/tsconfig.build.json source/tsconfig.json \
    source/webpack.config.ts source/webpack.meta.config.ts ./
RUN yarn build && \
    cp ./resources/assets/src/images/bg.webp ./public/app && \
    cp ./resources/assets/src/images/favicon.ico ./public/app


FROM php:7.4-apache
ARG CHANGE_SOURCE=false
RUN if [ ${CHANGE_SOURCE} = true ]; then \
        sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list && \
        sed -i 's/security.debian.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list && \
        sed -i 's/security-cdn.debian.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list \
    ;fi && \
    apt-get update && apt-get install -y \
        libfreetype6-dev \
        libpng-dev \
        libzip-dev && \
    rm -rf /var/lib/apt/lists/* && \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
    { \
		echo '[PHP]'; \
		echo 'post_max_size = 30M'; \
		echo 'upload_max_filesize = 20M'; \
	} | tee $PHP_INI_DIR/conf.d/tweak.ini && \
    docker-php-ext-configure gd --with-freetype && \
    docker-php-ext-install -j "$(nproc)" gd zip

WORKDIR /app
COPY source/ .
COPY --from=vendor /usr/bin/composer /usr/bin/composer
COPY --from=vendor /app ./
COPY --from=build /app/public/app ./public/app/
RUN composer dump-autoload -o --no-dev -n && \
    cp .env.example .env && \
    php artisan key:generate && \
    mv .env storage/ && \
    ln -s storage/.env .env && \
    touch storage/database.db && \
    mkdir storage/plugins && \
    chown -R www-data:www-data storage public && \
    sed 's/PLUGINS_DIR=null/PLUGINS_DIR=\/app\/storage\/plugins/' -i storage/.env && \
    sed 's/DB_CONNECTION=mysql/DB_CONNECTION=sqlite/' -i storage/.env && \
    sed 's/DB_DATABASE=blessingskin/DB_DATABASE=\/app\/storage\/database\.db/' -i storage/.env

ENV APACHE_DOCUMENT_ROOT /app/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf && \
    sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf && \
    a2enmod rewrite headers

EXPOSE 80

VOLUME ["/app/storage"]
