#!/bin/sh
set -e

cd /var/www/html

if ! grep -q "APP_KEY=base64" .env; then
    php artisan key:generate --force
fi

exec "$@"