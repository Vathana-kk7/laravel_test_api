#!/bin/bash
set -e

echo "🚀 Starting Laravel..."

# Install if missing
if [ ! -f vendor/autoload.php ]; then
    composer install --no-dev --optimize-autoloader
fi

# Generate key if not exists
if [ -z "$APP_KEY" ]; then
    php artisan key:generate --force
fi

# Clear cache
php artisan config:clear
php artisan config:cache

# Run migration (SAFE)
php artisan migrate:fresh --force || echo "Migration skipped"

echo "✅ Ready!"

php artisan serve --host=0.0.0.0 --port=10000
