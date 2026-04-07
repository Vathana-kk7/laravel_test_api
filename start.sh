#!/bin/bash

# Make sure the container doesn't exit on errors
set -e

# Ensure dependencies are installed
if [ ! -f vendor/autoload.php ]; then
    echo "📦 Installing dependencies..."
    composer install --no-dev --optimize-autoloader
fi

# Ensure application key is set
if ! grep -q "APP_KEY=" .env 2>/dev/null || [ -z "$APP_KEY" ]; then
    echo "🔑 Generating application key..."
    php artisan key:generate
fi

echo "⏳ Running migrations..."
php artisan migrate --force || echo "⚠️ Migrations failed (maybe already run)."

echo "✅ Migration done!"

echo "🚀 Starting Laravel development server..."
# Start server in foreground so Docker keeps running
php artisan serve --host=0.0.0.0 --port=10000
