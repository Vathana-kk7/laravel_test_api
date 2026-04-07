# Use PHP CLI with required extensions
FROM php:8.2-cli

# Set working directory
WORKDIR /var/www

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl zip unzip libzip-dev \
    && docker-php-ext-install zip pdo pdo_mysql \
    && apt-get clean

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy project files (initially)
COPY . .

# Make start script executable
RUN chmod +x start.sh

# Expose port (example 10000)
EXPOSE 10000

# Start container
CMD ["bash", "start.sh"]
