FROM php:8.2-cli

WORKDIR /var/www

RUN apt-get update && apt-get install -y \
    git curl zip unzip libzip-dev \
    && docker-php-ext-install zip pdo pdo_mysql \
    && apt-get clean

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

COPY . .

RUN composer install --no-dev --optimize-autoloader

RUN chmod -R 775 storage bootstrap/cache
RUN chmod +x start.sh

EXPOSE 10000

CMD ["bash", "start.sh"]
