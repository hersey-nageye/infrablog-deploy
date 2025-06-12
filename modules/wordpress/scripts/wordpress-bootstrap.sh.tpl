#!/bin/bash
set -e

# Install required packages
apt-get update -y
apt-get install -y unzip curl apache2 php php-mysql libapache2-mod-php mysql-client jq

# Enable and start Apache
systemctl enable apache2
systemctl start apache2

# Optional: Install Vault CLI
VAULT_VERSION="1.15.5"
VAULT_URL="https://releases.hashicorp.com/vault/$\{VAULT_VERSION}/vault_$\{VAULT_VERSION}_linux_amd64.zip"
curl -fsSL "$VAULT_URL" -o /tmp/vault.zip
unzip -q /tmp/vault.zip -d /usr/local/bin
chmod +x /usr/local/bin/vault

# Set Vault environment variables
export VAULT_ADDR="http://${vault_ip}:8200"
export VAULT_TOKEN="root"

# Attempt to retrieve DB secrets from Vault
if vault kv get -format=json secret/wordpress > /tmp/vault_secrets.json 2>/dev/null; then
  echo "[INFO] Retrieved secrets from Vault"
  DB_USER=$(jq -r '.data.data.DB_USER' /tmp/vault_secrets.json)
  DB_PASS=$(jq -r '.data.data.DB_PASS' /tmp/vault_secrets.json)
  DB_HOST=$(jq -r '.data.data.DB_HOST' /tmp/vault_secrets.json)
else
  echo "[WARN] Vault unavailable. Using fallback credentials"
  DB_USER="wp_user"
  DB_PASS="wp_pass"
  DB_HOST="localhost"
fi

# Download and install WordPress
cd /var/www/html
rm -f index.html
curl -fsSL https://wordpress.org/latest.tar.gz | tar -xz
cp -r wordpress/* .
rm -rf wordpress latest.tar.gz

# Create wp-config.php with DB credentials
cat > wp-config.php <<EOF
<?php
define('DB_NAME', 'wordpressdb');
define('DB_USER', '$\{DB_USER}');
define('DB_PASSWORD', '$\{DB_PASS}');
define('DB_HOST', '$\{DB_HOST}');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');
\$table_prefix = 'wp_';
define('WP_DEBUG', false);
if (!defined('ABSPATH')) define('ABSPATH', dirname(__FILE__) . '/');
require_once ABSPATH . 'wp-settings.php';
EOF

# Set correct permissions and restart Apache
chown -R www-data:www-data /var/www/html
systemctl restart apache2
