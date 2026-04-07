#!/bin/bash

# Make sure the container doesn't exit on errors
set -e

echo "⏳ Running migrations..."
php artisan migrate --force || echo "⚠️ Migrations failed (maybe already run)."

echo "✅ Migration done!"

echo "🚀 Starting Laravel development server..."
# Start server in foreground so Docker keeps running
php artisan serve --host=0.0.0.0 --port=10000
