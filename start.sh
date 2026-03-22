#!/bin/bash

echo "⏳ Running migrations..."
php artisan migrate --force
echo "✅ Migration done!"

echo "🚀 Starting server..."
php artisan serve --host=0.0.0.0 --port=10000
