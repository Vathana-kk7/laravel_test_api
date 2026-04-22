#!/bin/bash
set -e

echo "🚀 Starting Laravel..."

# Validate DB credentials exist (Render provides these as RENDER_* env vars)
if [ -z "$DB_HOST" ] || [ -z "$DB_DATABASE" ]; then
    echo "⚠️  Database environment variables not set. Checking Render variables..."

    # Render sets RENDER_MYSQL_HOST etc. Try to extract from those
    if [ ! -z "$RENDER_MYSQL_HOST" ]; then
        export DB_HOST=$RENDER_MYSQL_HOST
        export DB_PORT=${RENDER_MYSQL_PORT:-3306}
        export DB_DATABASE=$RENDER_MYSQL_DATABASE
        export DB_USERNAME=$RENDER_MYSQL_USERNAME
        export DB_PASSWORD=$RENDER_MYSQL_PASSWORD
        echo "✅ Using Render MySQL environment variables"
    else
        echo "⚠️  No database configured - DB operations may fail"
    fi
fi

# Install if missing
if [ ! -f vendor/autoload.php ]; then
    composer install --no-dev --optimize-autoloader
fi

# Generate key if not exists
if [ -z "$APP_KEY" ]; then
    php artisan key:generate --force
fi

# Clear cache
composer dump-autoload
php artisan config:clear
php artisan cache:clear
php artisan route:clear

# Wait for database to be ready
if [ "$DB_CONNECTION" = "mysql" ] || [ "$DB_CONNECTION" = "pgsql" ]; then
    echo "⏳ Waiting for database..."
    
    db_ready=0
    for i in $(seq 1 30); do
        if php -r "
            require __DIR__.'/vendor/autoload.php';
            \$app = require_once __DIR__.'/bootstrap/app.php';
            \$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();
            try {
                DB::connection()->getPdo();
                echo 'OK';
            } catch (Exception \$e) {
                echo 'FAIL';
            }
        " 2>/dev/null | grep -q 'OK'; then
            
            echo "✅ Database connected!"
            db_ready=1
            break
        fi
        
        echo "🔄 Attempt $i/30..."
        sleep 2
    done
    
    if [ $db_ready -eq 0 ]; then
        echo "⚠️  Database not ready after 30 attempts. Continuing anyway..."
    fi
fi

# Cache config
php artisan config:cache

# Run migration
php artisan migrate --force

echo "✅ Ready!"

# Use $PORT (Render sets this env var)
php artisan serve --host=0.0.0.0 --port=$PORT


