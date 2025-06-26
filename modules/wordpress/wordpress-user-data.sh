#!/bin/bash

# Install required packages
apt update -y
apt install apache2 php php-mysql php-curl php-gd php-xml php-zip mysql-server wget unzip jq curl -y

# Remove default Apache page
rm -f /var/www/html/index.html

# Download and install WordPress
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* /var/www/html/
rm -rf wordpress latest.tar.gz

# Function to get credentials from Vault
get_vault_credentials() {
    local vault_addr="${vault_addr}"
    local vault_token
    
    # Get Vault token using userpass auth
    vault_token=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d "{\"password\":\"${wp_vault_password}\"}" \
        "$vault_addr/v1/auth/userpass/login/wordpress" | jq -r '.auth.client_token')
    
    # Get WordPress credentials from Vault
    local creds=$(curl -s -H "X-Vault-Token: $vault_token" \
        "$vault_addr/v1/secret/data/wordpress" | jq -r '.data.data')
    
    DB_NAME=$(echo $creds | jq -r '.db_name')
    DB_USER=$(echo $creds | jq -r '.db_user')
    DB_PASSWORD=$(echo $creds | jq -r '.db_password')
}

# Get credentials from Vault
get_vault_credentials

# Set up MySQL
mysql -e "CREATE DATABASE $DB_NAME DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Create wp-config.php
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sed -i "s/database_name_here/$DB_NAME/" /var/www/html/wp-config.php
sed -i "s/username_here/$DB_USER/" /var/www/html/wp-config.php
sed -i "s/password_here/$DB_PASSWORD/" /var/www/html/wp-config.php

# Add WordPress salt keys
curl -s https://api.wordpress.org/secret-key/1.1/salt/ > /tmp/wp-salt.txt
sed -i '/put your unique phrase here/r /tmp/wp-salt.txt' /var/www/html/wp-config.php
sed -i '/put your unique phrase here/d' /var/www/html/wp-config.php
rm /tmp/wp-salt.txt

# Set permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Enable mod_rewrite
a2enmod rewrite

# Update Apache config for WordPress
sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# Restart Apache
systemctl restart apache2

echo "WordPress setup complete!"
echo "Database: $DB_NAME"
echo "User: $DB_USER"