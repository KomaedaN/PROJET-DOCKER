#!/bin/sh
set -e

cd /var/www/html
cp -n /var/www/html/.env1 /var/www/html/.env
php-fpm8.1 -F

if ! grep -qE "^APP_KEY=base64:" .env; then
    php artisan key:generate --force && php artisan migrate:fresh --seed
fi


exec "$@"