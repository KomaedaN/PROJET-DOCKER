#version < 8.2 
FROM php:8.1-fpm

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
WORKDIR /var/www/html
COPY composer.json composer.lock ./
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    curl \
    gnupg \
 && docker-php-ext-install zip pdo pdo_mysql

RUN composer self-update
RUN composer install --no-scripts

COPY . .

# Donner les permissions laravel
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

#Copier le fichier entrypoint.sh qui va ensuite vérifier si une clé doit être générée
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["php-fpm", "-F"]