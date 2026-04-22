#!/bin/bash

echo "🚀 Starting Laravel..."

# Disable Composer scripts by default to prevent DB access during install
export COMPOSER_DISABLE_XDEBUG_WARN=1

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

# Install dependencies if missing (skip all Composer scripts to avoid DB access)
if [ ! -f vendor/autoload.php ]; then
    echo "📦 Installing Composer dependencies..."
    composer install --no-dev --optimize-autoloader --no-scripts --prefer-dist
fi

# Generate key if not exists
if [ -z "$APP_KEY" ]; then
    php artisan key:generate --force
fi

# Clear cache (safe even without DB)
php artisan config:clear 2>/dev/null || true
php artisan cache:clear 2>/dev/null || true
php artisan route:clear 2>/dev/null || true

# Wait for database to be ready (only if DB_HOST is set)
if [ ! -z "$DB_HOST" ] && [ ! -z "$DB_DATABASE" ]; then
    echo "⏳ Waiting for database connection to $DB_HOST:$DB_PORT..."
    
    # Test raw TCP connectivity first (diagnoses network vs DB)
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
        echo "⚠️  Database not ready after 30 attempts. Migrations will fail..."
        echo "📋 Check: 1) CA certificate uploaded (MYSQL_ATTR_SSL_CA) 2) DB accessible publicly 3) Render outbound networking enabled"
    else
        # DB is ready — run Composer dump-autoload (no scripts) then manually discover packages
        echo "📦 Running Composer dump-autoload (no scripts)..."
        composer dump-autoload --optimize --no-scripts
        
        echo "🔧 Discovering packages..."
        if php artisan package:discover --ansi; then
            echo "✅ Package discovery complete"
        else
            echo "⚠️  Package discovery failed"
        fi
        
        # Cache config after discovery
        php artisan config:cache
    fi
else
    echo "⚠️  DB_HOST or DB_DATABASE not set — skipping DB operations"
fi

# Run migration (best effort — may fail if DB unreachable)
echo "📦 Running migrations..."
php artisan migrate --force || echo "⚠️  Migrations failed — app may have limited functionality"

echo "✅ Ready!"

# Use $PORT (Render sets this env var)
php artisan serve --host=0.0.0.0 --port=$PORT
