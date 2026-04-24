#!/bin/bash

echo "Starting Laravel setup..."

export COMPOSER_DISABLE_XDEBUG_WARN=1

if [ -z "$DB_HOST" ] || [ -z "$DB_DATABASE" ]; then
    echo "Checking Render environment variables..."
    
    if [ ! -z "$RENDER_MYSQL_HOST" ]; then
        export DB_HOST=$RENDER_MYSQL_HOST
        export DB_PORT=${RENDER_MYSQL_PORT:-3306}
        export DB_DATABASE=$RENDER_MYSQL_DATABASE
        export DB_USERNAME=$RENDER_MYSQL_USERNAME
        export DB_PASSWORD=$RENDER_MYSQL_PASSWORD
        export DB_SSL=true
        echo "Using Railway MySQL environment variables"
    fi
fi

if [ ! -f vendor/autoload.php ]; then
    echo "Installing Composer dependencies..."
    composer install --no-dev --optimize-autoloader --no-scripts --prefer-dist
fi

if [ -z "$APP_KEY" ]; then
    php artisan key:generate --force
fi

php artisan config:clear 2>/dev/null || true
php artisan cache:clear 2>/dev/null || true
php artisan route:clear 2>/dev/null || true

if [ -n "$DB_HOST" ] && [ -n "$DB_DATABASE" ]; then
    echo "Waiting for database connection to $DB_HOST:$DB_PORT..."
    
    # Test raw TCP connectivity first
    echo "Testing TCP to $DB_HOST:$DB_PORT..."
    timeout=5
    nc -zvw"$timeout" "$DB_HOST" "$DB_PORT" &>/dev/null
    if [ $? -eq 0 ]; then
        echo "TCP OK"
    fi
    
    echo "Waiting for database (max 60s)..."
    max_attempts=30
    attempt=1
    
    until php -r "
        require __DIR__.'/vendor/autoload.php';
        \$app = require_once __DIR__.'/bootstrap/app.php';
        \$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();
        try {
            DB::connection()->getPdo();
            exit(0);
        } catch (Exception \$e) {
            exit(1);
        }
    " 2>/dev/null; do
        if [ $attempt -ge $max_attempts ]; then
            echo "Database not ready after ${max_attempts}x2s. Continuing..."
            break
        fi
        echo "DB attempt $attempt/$max_attempts..."
        sleep 2
        attempt=$((attempt + 1))
    done
    echo "Database check complete"
    
    echo "Running Composer dump-autoload..."
    composer dump-autoload --optimize --no-scripts || true
    
    php artisan package:discover --ansi || true
    php artisan config:cache || true
    
    echo "Running migrations..."
    php artisan migrate --force || echo "Migrations failed"
else
    echo "DB_HOST or DB_DATABASE not set - skipping DB operations"
fi

echo "Setup complete - starting services..."
exec supervisord -c /etc/supervisor/conf.d/supervisord.conf