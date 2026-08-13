FROM php:8.4-fpm

# Dependencias del sistema
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpq-dev \
    libzip-dev \
    zip \
    curl \
    nodejs \
    npm \
    && docker-php-ext-install pdo_pgsql pgsql bcmath zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Directorio de trabajo
WORKDIR /var/www/html

# Copiar proyecto
COPY FreezerGuard/ /var/www/html/

# Dependencias PHP
RUN composer install \
    --no-dev \
    --optimize-autoloader \
    --no-interaction

# Dependencias JS y build de Vite
RUN npm ci && npm run build

# Permisos de Laravel
RUN chown -R www-data:www-data \
    storage \
    bootstrap/cache

EXPOSE 9000

CMD ["php-fpm"]