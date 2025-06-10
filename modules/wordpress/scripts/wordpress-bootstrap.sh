#!/bin/bash

set -e

# Update and install packages
apt-get update -y
apt-get install -y unzip curl apache2 php php-mysql libapache2-mod-php mysql-client jq

# Enable Apache to start on boot
systemctl enable apache2

# Install Vault CLI (optional for dev testing, not required if secrets are mocked)
cd /tmp
curl -O https://releases.hashicorp.com/vault/1.15.5/vault_1.15.5_linux_amd64.zip
unzip vault_1.15.5_linux_amd64.zip
mv vault /usr/local/bin/
chmod +x /usr/local/bin/vault

# Set Vault env (optional, fallback hardcoded secrets used below)
export VAULT_ADDR="http://10.0.1.141:8200"
export VAULT_TOKEN="root"

# Try fetching secrets from Vault, or use fallback values
if vault kv get -format=json secret/wordpress > /tmp/vault_secrets.json 2>/dev/null; then
  echo "[INFO] Secrets retrieved from Vault."
  DB_USER=$(jq -r '.data.data.DB_USER' /tmp/vault_secrets.json)
  DB_PASS=$(jq -r '.data.data.DB_PASS' /tmp/vault_secrets.json)
  DB_HOST=$(jq -r '.data.data.DB_HOST' /tmp/vault_secrets.json)
else
  echo "[WARN] Vault unavailable. Using fallback secrets."
  DB_USER="wp_user"
  DB_PASS="wp_pass"
  DB_HOST="localhost"
fi

# Download and install WordPress
cd /var/www/html
rm -f index.html
curl -O https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* .
rm -rf wordpress latest.tar.gz

# Configure WordPress
cat > wp-config.php <<EOF
<?php
define( 'DB_NAME', 'wordpressdb' );
define( 'DB_USER', '${DB_USER}' );
define( 'DB_PASSWORD', '${DB_PASS}' );
define( 'DB_HOST', '${DB_HOST}' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );
\$table_prefix = 'wp_';
define( 'WP_DEBUG', false );
if ( !defined('ABSPATH') ) define('ABSPATH', dirname(__FILE__) . '/');
require_once(ABSPATH . 'wp-settings.php');
EOF

# Permissions and restart
chown -R www-data:www-data /var/www/html
systemctl restart apache2
