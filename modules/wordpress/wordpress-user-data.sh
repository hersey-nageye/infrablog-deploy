#!/bin/bash
exec > >(tee /var/log/wp-setup.log | logger -t wp-setup) 2>&1
set -euxo pipefail

# Environment variables passed via Terraform templatefile()
DB_NAME="wordpressdb"
DB_USER="wp_user"
DB_PASSWORD="StrongPassword123!"

# Update and install packages
apt update -y
apt install -y apache2 php php-mysql php-curl php-gd php-xml php-zip mysql-server wget unzip jq curl

# Remove default Apache index page
rm -f /var/www/html/index.html

# Enable Apache modules
a2enmod rewrite
systemctl enable apache2
systemctl start apache2

# Configure Apache to allow .htaccess overrides
sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
systemctl restart apache2

# Download and extract WordPress
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* /var/www/html/
rm -rf wordpress latest.tar.gz

# Create the MySQL DB and user
mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "CREATE USER IF NOT EXISTS '${DB_NAME}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Configure wp-config.php
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sed -i "s/database_name_here/${DB_NAME}/" /var/www/html/wp-config.php
sed -i "s/username_here/${DB_USER}/" /var/www/html/wp-config.php
sed -i "s/password_here/${DB_PASSWORD}/" /var/www/html/wp-config.php

# Add WordPress security salts
curl -s https://api.wordpress.org/secret-key/1.1/salt/ > /tmp/wp-salt.txt
sed -i '/put your unique phrase here/r /tmp/wp-salt.txt' /var/www/html/wp-config.php
sed -i '/put your unique phrase here/d' /var/www/html/wp-config.php
rm /tmp/wp-salt.txt

# Set permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Final restart
systemctl restart apache2

echo "✅ WordPress setup completed successfully."
