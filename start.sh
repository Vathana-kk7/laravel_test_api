#!/bin/bash

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

# Wait for database to be ready (only if DB_HOST is set)
if [ ! -z "$DB_HOST" ] && [ ! -z "$DB_DATABASE" ]; then
    echo "⏳ Waiting for database connection to $DB_HOST:$DB_PORT..."
    
    # First, test raw TCP connectivity (bypasses Laravel/PDO to diagnose network)
    echo "🔍 Testing raw TCP connection..."
    if php -r "
        \$host = getenv('DB_HOST');
        \$port = getenv('DB_PORT') ?: 3306;
        \$s = fsockopen(\$host, (int)\$port, \$errno, \$errstr, 5);
        if (!\$s) {
            echo \"FAIL: \$errstr (\$errno)\";
        } else {
            echo 'OK';
            fclose(\$s);
        }
    " 2>/dev/null | grep -q 'OK'; then
        echo "✅ TCP connection established"
    else
        echo "❌ Cannot reach $DB_HOST:$DB_PORT — Render outbound networking may be blocked"
        echo "📋 Fix: Render Dashboard → Service → Settings → Enable 'Outbound Networking'"
        echo "📋 Or migrate DB to Render's native MySQL/PostgreSQL service"
    fi
    
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
                echo 'FAIL: '.\$e->getMessage();
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
        echo "⚠️  Database not ready after 30 attempts. Migrations may fail..."
        echo "📋 Check: 1) CA certificate uploaded and MYSQL_ATTR_SSL_CA set 2) DB is publicly accessible"
    fi
else
    echo "⚠️  DB_HOST or DB_DATABASE not set — skipping DB wait"
fi

# Cache config
php artisan config:cache

# Run migration (best effort)
echo "📦 Running migrations..."
if ! php artisan migrate --force; then
    echo "⚠️  Migrations failed — continuing anyway (app may have limited functionality)"
fi

echo "✅ Ready!"

# Use $PORT (Render sets this env var)
php artisan serve --host=0.0.0.0 --port=$PORT


