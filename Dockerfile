FROM composer:2 as composer

WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-scripts

FROM php:8.2-fpm

# Install system deps
RUN apt-get update && apt-get install -y \
    git curl libzip-dev unzip nginx-full supervisor netcat-openbsd \
    && docker-php-ext-install zip pdo pdo_mysql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy composer vendor
COPY --from=composer /app/vendor /var/www/vendor

WORKDIR /var/www
COPY . .
COPY nginx.conf /etc/nginx/sites-available/default
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Build assets
RUN npm ci --only=production \
    && npm run build \
    && rm -rf node_modules

# Permissions
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache \
    && sed -i 's/\r//' start.sh \
    && chmod +x start.sh

# Run start.sh (which will exec supervisord at the end)
CMD ["/bin/bash", "/var/www/start.sh"]