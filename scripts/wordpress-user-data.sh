#!/bin/bash
exec > >(tee /var/log/wp-setup.log | logger -t wp-setup) 2>&1
set -euxo pipefail

# Variables
VAULT_ADDR="http://${vault_private_ip}:8200"
VAULT_TOKEN="${vault_token}"
DB_HOST="${db_host}"
DB_NAME="${db_name}"

# Install dependencies
apt-get update
apt-get install -y apache2 php php-mysql unzip curl jq
systemctl enable apache2
systemctl start apache2

# Install Vault CLI
VAULT_VERSION="1.15.5"
wget -q https://releases.hashicorp.com/vault/$VAULT_VERSION/vault_${VAULT_VERSION}_linux_amd64.zip
unzip vault_${VAULT_VERSION}_linux_amd64.zip
mv vault /usr/local/bin/
chmod +x /usr/local/bin/vault
rm vault_${VAULT_VERSION}_linux_amd64.zip

# Download and install WordPress
wget https://wordpress.org/latest.zip
unzip latest.zip
cp -r wordpress/* /var/www/html/
chown -R www-data:www-data /var/www/html/
rm -rf wordpress latest.zip /var/www/html/index.html

# Wait for Vault to be ready and for the secret to exist
for i in {1..30}; do
  if curl -s "$VAULT_ADDR/v1/sys/health" >/dev/null 2>&1 && \
     curl -s "$VAULT_ADDR/v1/secret/data/wordpress" -H "X-Vault-Token: $VAULT_TOKEN" | jq . >/dev/null 2>&1; then
    echo "Vault is ready and secret found."
    break
  fi
  echo "Waiting for Vault... attempt $i"
  sleep 5
done

# Fetch credentials from Vault
CREDS=$(vault kv get -format=json secret/wordpress)
DB_USER=$(echo "$CREDS" | jq -r .data.data.username)
DB_PASS=$(echo "$CREDS" | jq -r .data.data.password)

# Generate wp-config.php
cat <<EOF > /var/www/html/wp-config.php
<?php
define('DB_NAME', '$DB_NAME');
define('DB_USER', '$DB_USER');
define('DB_PASSWORD', '$DB_PASS');
define('DB_HOST', '$DB_HOST');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');
\$table_prefix = 'wp_';
define('WP_DEBUG', false);
if (!defined('ABSPATH')) define('ABSPATH', dirname(__FILE__) . '/');
require_once(ABSPATH . 'wp-settings.php');
EOF

chown www-data:www-data /var/www/html/wp-config.php
systemctl restart apache2

echo "WordPress setup completed successfully."
