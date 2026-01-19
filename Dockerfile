# FROM php:8.2-fpm-alpine

# # Install dependencies
# RUN apk add --no-cache \
#     nginx \
#     curl \
#     bash \
#     libzip-dev \
#     libpng-dev \
#     libjpeg-turbo-dev \
#     freetype-dev \
#     oniguruma-dev \
#     zip \
#     git \
#     && docker-php-ext-configure gd \
#         --with-freetype \
#         --with-jpeg \
#     && docker-php-ext-install \
#         pdo_mysql \
#         mbstring \
#         exif \
#         pcntl \
#         bcmath \
#         zip \
#         gd

# RUN sed -i 's/^user = .*/user = root/' /usr/local/etc/php-fpm.d/www.conf && \
#     sed -i 's/^group = .*/group = root/' /usr/local/etc/php-fpm.d/www.conf

# # Install Composer
# COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# # Nginx config
# COPY docker/nginx.conf /etc/nginx/nginx.conf

# # Workdir
# WORKDIR /var/www

# # Permissions
# # RUN chown -R www-data:www-data /var/www
# # RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# # Expose ports
# EXPOSE 80

# # Startup script
# COPY docker/start.sh /start.sh
# RUN chmod +x /start.sh

# CMD ["/start.sh"]


FROM php:8.2-fpm-alpine

# Install dependencies
RUN apk add --no-cache \
    nginx \
    curl \
    bash \
    zip \
    git \
    nodejs \
    npm \
    oniguruma-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    icu-dev \
    postgresql-dev \
    libxml2-dev \
    && docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
    && docker-php-ext-install \
       pdo_mysql \
       pdo_pgsql \
       pgsql \
       mbstring \
       exif \
       pcntl \
       bcmath \
       zip \
       gd \
       intl \
       xml \
       fileinfo \
       opcache

# Install Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Nginx config
COPY docker/nginx.conf /etc/nginx/nginx.conf

# Workdir
WORKDIR /var/www

# Permissions
# RUN chown -R www-data:www-data /var/www
# RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

RUN composer install --no-interaction --prefer-dist --optimize-autoloader \
    && npm install \
    && npm run build

# Expose ports
EXPOSE 80

# Startup script
COPY docker/start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]