FROM composer:2 as composer

WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-scripts

FROM php:8.2-fpm

# Install system deps
RUN apt-get update && apt-get install -y \
    git curl libzip-dev unzip nginx-full supervisor netcat-openbsd \
    libpq-dev \
    && docker-php-ext-install zip pdo pdo_mysql pdo_pgsql pgsql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy composer vendor
COPY --from=composer /app/vendor /var/www/vendor

WORKDIR /var/www

COPY package.json package-lock.json ./

RUN node --version && npm --version && ls -la package*.json

RUN npm ci

COPY . .
COPY nginx.conf /etc/nginx/sites-available/default
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN npm run build && rm -rf node_modules

RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache \
    && sed -i 's/\r//' start.sh \
    && chmod +x start.sh

CMD ["/bin/bash", "/var/www/start.sh"]
