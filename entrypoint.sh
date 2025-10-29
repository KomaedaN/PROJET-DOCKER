#!/bin/sh
set -e

cd /var/www/html

if ! grep -qE "^APP_KEY=base64:" .env; then
    php artisan key:generate --force && php artisan migrate:fresh --seed
fi

exec "$@"