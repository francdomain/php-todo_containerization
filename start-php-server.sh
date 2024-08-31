#!/bin/bash

# Wait for the MySQL database to be ready
echo "Waiting for MySQL to be ready..."

# Loop until the MySQL service is available
while ! mysqladmin ping -h"$DB_HOST" --silent; do
    sleep 2
    echo "Waiting for MySQL..."
done

echo "MySQL is ready."

# Run Laravel commands
php artisan migrate --force
php artisan db:seed --force
php artisan config:cache
php artisan cache:clear
php artisan route:clear

# Start Laravel server
php artisan serve --host=0.0.0.0 --port=8000