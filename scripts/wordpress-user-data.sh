#!/bin/bash
exec > >(tee /var/log/wp-setup.log | logger -t wp-setup) 2>&1
set -euxo pipefail

# Export required environment variables
export VAULT_ADDR="http://${vault_private_ip}:8200"
export VAULT_TOKEN="${vault_token}"

# Other config
DB_HOST="${db_host}"
DB_NAME="${db_name}"

# Install dependencies
apt-get update
apt-get install -y apache2 php php-mysql php-curl php-gd php-xml php-mbstring php-zip unzip curl jq mysql-client

# Enable required PHP modules
phpenmod curl gd xml mbstring zip

systemctl enable apache2
systemctl start apache2

# Configure Apache
cat <<EOF > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    ErrorLog /var/log/apache2/error.log
    CustomLog /var/log/apache2/access.log combined
    <Directory /var/www/html>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

a2enmod rewrite
systemctl reload apache2

# Install Vault CLI
VAULT_VERSION="1.15.5"
wget -q https://releases.hashicorp.com/vault/$VAULT_VERSION/vault_${VAULT_VERSION}_linux_amd64.zip
unzip vault_${VAULT_VERSION}_linux_amd64.zip
mv vault /usr/local/bin/
chmod +x /usr/local/bin/vault
rm vault_${VAULT_VERSION}_linux_amd64.zip

# Download and install WordPress
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar xzf latest.tar.gz
cp -r wordpress/* /var/www/html/
chown -R www-data:www-data /var/www/html/
rm -rf wordpress latest.tar.gz /var/www/html/index.html

# Wait for Vault to be reachable with better error handling
echo "Waiting for Vault to be ready..."
VAULT_READY=false
for i in {1..60}; do
  if curl -s http://${vault_private_ip}:8200/v1/sys/health >/dev/null 2>&1; then
    echo "Vault is up at attempt $i!"
    VAULT_READY=true
    break
  fi
  echo "Attempt $i: Vault not ready yet, waiting..."
  sleep 10
done

if [ "$VAULT_READY" = false ]; then
  echo "ERROR: Vault is not reachable after 10 minutes. Exiting."
  exit 1
fi

# Additional wait to ensure Vault is fully configured
sleep 30

# Test Vault connection and authentication
echo "Testing Vault connection..."
if ! vault auth -method=token token="$VAULT_TOKEN" >/dev/null 2>&1; then
  echo "ERROR: Cannot authenticate with Vault"
  exit 1
fi

# Fetch credentials from Vault with error handling
echo "Fetching credentials from Vault..."
if ! CREDS=$(vault kv get -format=json secret/wordpress 2>/dev/null); then
  echo "ERROR: Cannot fetch credentials from Vault"
  echo "Vault status:"
  vault status || true
  echo "Available secrets:"
  vault kv list secret/ || true
  exit 1
fi

DB_USER=$(echo "$CREDS" | jq -r .data.data.username)
DB_PASS=$(echo "$CREDS" | jq -r .data.data.password)

if [ "$DB_USER" = "null" ] || [ "$DB_PASS" = "null" ]; then
  echo "ERROR: Retrieved credentials are null"
  echo "Credentials response: $CREDS"
  exit 1
fi

echo "Successfully retrieved credentials for user: $DB_USER"

# Test database connection
echo "Testing database connection..."
if ! mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" >/dev/null 2>&1; then
  echo "ERROR: Cannot connect to database"
  exit 1
fi
echo "Database connection successful"

# Generate WordPress salts
SALTS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)

# Generate wp-config.php with proper salts
cat <<EOF > /var/www/html/wp-config.php
<?php
define('DB_NAME', '$DB_NAME');
define('DB_USER', '$DB_USER');
define('DB_PASSWORD', '$DB_PASS');
define('DB_HOST', '$DB_HOST');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

$SALTS

\$table_prefix = 'wp_';

define('WP_DEBUG', false);
define('WP_DEBUG_LOG', false);
define('WP_DEBUG_DISPLAY', false);

/* Add any custom values here */

if (!defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}

require_once ABSPATH . 'wp-settings.php';
EOF

chown www-data:www-data /var/www/html/wp-config.php
chmod 644 /var/www/html/wp-config.php

# Install WordPress via WP-CLI for automated setup
echo "Installing WP-CLI..."
curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/v2.8.1/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# Install WordPress core (this creates the database tables)
echo "Installing WordPress core..."
cd /var/www/html
sudo -u www-data wp core install \
  --url="http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)" \
  --title="WordPress Site" \
  --admin_user="admin" \
  --admin_password="$(openssl rand -base64 12)" \
  --admin_email="admin@example.com" \
  --skip-email

# Restart Apache
systemctl restart apache2

echo "WordPress setup completed successfully."
echo "WordPress admin password: $(sudo -u www-data wp user get admin --field=user_pass 2>/dev/null || echo 'Password not retrievable')"
echo "Site URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"