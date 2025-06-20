#!/bin/bash
exec > >(tee /var/log/vault-setup.log | logger -t vault-setup) 2>&1
set -euxo pipefail

# Variables
DB_USER="${db_user}"
DB_PASS="${db_pass}"

# Install dependencies
apt-get update
apt-get install -y unzip jq curl

# Install Vault
VAULT_VERSION="1.15.5"
wget -q https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip
unzip vault_${VAULT_VERSION}_linux_amd64.zip
mv vault /usr/local/bin/
chmod +x /usr/local/bin/vault
rm vault_${VAULT_VERSION}_linux_amd64.zip

# Start Vault in dev mode
nohup vault server -dev -dev-listen-address="0.0.0.0:8200" > /root/vault.log 2>&1 &

# Wait for Vault to be ready
export VAULT_ADDR="http://127.0.0.1:8200"
for i in {1..30}; do
  if curl -s "$VAULT_ADDR/v1/sys/health" >/dev/null 2>&1; then
    echo "Vault is ready."
    break
  fi
  sleep 2
done

# Extract the root token
sleep 5
VAULT_TOKEN=$(grep 'Root Token:' /root/vault.log | awk '{print $NF}')
export VAULT_TOKEN

# Enable KV secrets engine at path "secret"
vault secrets enable -path=secret kv || true

# Store static credentials
vault kv put secret/wordpress username="$DB_USER" password="$DB_PASS"

# Create WordPress read-only policy
cat <<EOF > /root/wordpress-policy.hcl
path "secret/data/wordpress" {
  capabilities = ["read"]
}
EOF

vault policy write wordpress-policy /root/wordpress-policy.hcl

# Generate a token for WordPress and save it
vault token create -policy=wordpress-policy -format=json \
  | jq -r .auth.client_token > /root/wordpress-token.txt

# Indicate setup completion
echo "Vault setup completed at $(date)" > /root/vault-ready
