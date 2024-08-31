# Use the official PHP image as the base image
FROM php:7.4-fpm

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
  libpng-dev \
  libjpeg-dev \
  libfreetype6-dev \
  libjpeg62-turbo-dev \
  libicu-dev \
  g++ \
  git \
  unzip \
  libzip-dev \
  libmysqlclient-dev \
  lsb-release \
  gnupg \
  wget

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN rm -rf /usr/src/php/ext/*/.libs

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install -j$(nproc) gd \
  && docker-php-ext-install pdo_mysql \
  && docker-php-ext-install mysqli \
  && docker-php-ext-install intl \
  && docker-php-ext-install zip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN echo "deb http://repo.mysql.com/apt/debian/ $(lsb_release -cs) mysql-8.0" > /etc/apt/sources.list.d/mysql.list \
  && curl -O https://repo.mysql.com/RPM-GPG-KEY-mysql \
  && apt-key add RPM-GPG-KEY-mysql \
  && apt-get update

# Install MySQL client
RUN apt-get install -y default-mysql-client

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
  chmod +x /usr/local/bin/composer

# Verify Composer installation
RUN /usr/local/bin/composer --version

WORKDIR /var/www

# Copy existing application directory contents
COPY . /var/www

# Copy existing application directory permissions
COPY --chown=www-data:www-data . /var/www

# Ensure storage and bootstrap/cache directories are writable
RUN chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Install Laravel dependencies
RUN /usr/local/bin/composer install --no-interaction --optimize-autoloader

# Set the correct permissions for Laravel folders
RUN chown -R www-data:www-data /var/www/bootstrap/cache /var/www/storage

# Change current user to www
USER www-data

# Generate application key and set it in .env
RUN php artisan key:generate && \
  echo "APP_KEY=$(php artisan key:generate --show)" >> /var/www/.env

RUN chmod +x start-php-server.sh

# Expose port 8000 and start php-fpm server
EXPOSE 8000

CMD ["php-fpm"]

ENTRYPOINT ["bash", "start-php-server.sh"]