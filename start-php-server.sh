#!/bin/bash

# Wait for database service to be available
until curl -s http://db:3306 > /dev/null; do
  echo "Waiting for database service..."
  sleep 5
done

php artisan migrate --force
php artisan db:seed --force
php artisan cache:clear
php artisan config:clear
php artisan route:clear

php artisan serve  --host=0.0.0.0