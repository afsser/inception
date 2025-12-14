#!/bin/bash

# Aguardar MariaDB estar pronto (com timeout)
echo "Waiting for MariaDB to be ready..."
TIMEOUT=30
COUNTER=0
until mysqladmin ping -h"mariadb" --silent; do
    echo "MariaDB is unavailable - sleeping"
    sleep 2
    COUNTER=$((COUNTER+2))
    if [ $COUNTER -ge $TIMEOUT ]; then
        echo "ERROR: MariaDB did not become ready in time"
        exit 1
    fi
done
echo "MariaDB is up - continuing..."

cd /var/www/html
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar

echo "Downloading WordPress..."
./wp-cli.phar core download --allow-root

echo "Creating wp-config.php..."
./wp-cli.phar config create --dbname="$MYSQL_DATABASE" --dbuser="$MYSQL_USER" --dbpass="$MYSQL_PASSWORD" --dbhost=mariadb --allow-root

echo "Installing WordPress..."
./wp-cli.phar core install --url="$DOMAIN_NAME" --title="$WP_TITLE" --admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PASSWORD" --admin_email="$WP_ADMIN_EMAIL" --allow-root

echo "Creating subscriber user..."
./wp-cli.phar user create "$WP_USER" "$WP_USER_EMAIL" --role=subscriber --user_pass="$WP_USER_PASSWORD" --allow-root

echo "WordPress setup complete! Starting php-fpm..."
php-fpm7.4 -F