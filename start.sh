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
    echo "🔍 Testing TCP to $DB_HOST:$DB_PORT..."
    timeout=5 nc -zvw$timeout $DB_HOST $DB_PORT &>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ TCP OK"
    else
        echo "❌ TCP failed - check Render outbound networking or DB firewall"
    fi

    echo "⏳ Waiting for database (max 60s)..."
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
            echo "⚠️ Database not ready after ${max_attempts}x2s. Continuing..."
            echo "💡 Upload MYSQL_ATTR_SSL_CA to Render if using SSL MySQL"
            break
        fi
        echo "🔄 DB attempt $attempt/$max_attempts..."
        sleep 2
        ((attempt++))
    done
    echo "✅ Database ready!"

    # Now safe to run composer dump-autoload and discover
    composer dump-autoload --optimize --no-scripts || true
    php artisan package:discover --ansi || true
    php artisan config:cache || true
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

# Run migrations only if DB ready (after wait loop)
echo "📦 Running migrations..."
php artisan migrate --force || echo "⚠️ Migrations failed (check DB logs)"

echo "✅ Ready!"

# Use $PORT (Render sets this env var)
# Setup complete - supervisor will start nginx/php-fpm
echo "🚀 App setup complete. Supervisor starting services..."

