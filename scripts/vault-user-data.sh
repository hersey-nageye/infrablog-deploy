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

# Create vault user and directories
useradd --system --home /etc/vault.d --shell /bin/false vault
mkdir -p /opt/vault/data
mkdir -p /etc/vault.d
chown -R vault:vault /opt/vault/data
chown -R vault:vault /etc/vault.d

# Create Vault configuration for dev mode but with proper setup
cat <<EOF > /etc/vault.d/vault.hcl
ui = true
disable_mlock = true

storage "file" {
  path = "/opt/vault/data"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

api_addr = "http://0.0.0.0:8200"
cluster_addr = "https://0.0.0.0:8201"
EOF

chown vault:vault /etc/vault.d/vault.hcl

# Create systemd service for Vault
cat <<EOF > /etc/systemd/system/vault.service
[Unit]
Description=HashiCorp Vault
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault.d/vault.hcl
StartLimitIntervalSec=60
StartLimitBurst=3

[Service]
Type=notify
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP \$MAINPID
KillMode=process
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
StartLimitInterval=60
StartLimitBurst=3
LimitNOFILE=65536
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
EOF

# Start Vault service
systemctl daemon-reload
systemctl enable vault
systemctl start vault

# Wait for Vault to be ready
export VAULT_ADDR="http://127.0.0.1:8200"
echo "Waiting for Vault to start..."
for i in {1..60}; do
  if curl -s "$VAULT_ADDR/v1/sys/health" >/dev/null 2>&1; then
    echo "Vault is ready."
    break
  fi
  sleep 2
done

# Initialize Vault (only if not already initialized)
if ! vault status | grep -q "Initialized.*true"; then
  echo "Initializing Vault..."
  vault operator init -key-shares=1 -key-threshold=1 -format=json > /root/vault-init.json
  
  # Extract unseal key and root token
  UNSEAL_KEY=$(jq -r '.unseal_keys_b64[0]' /root/vault-init.json)
  VAULT_TOKEN=$(jq -r '.root_token' /root/vault-init.json)
  
  # Unseal Vault
  vault operator unseal "$UNSEAL_KEY"
  
  # Set token for subsequent operations
  export VAULT_TOKEN
  
  # Enable KV secrets engine at path "secret"
  vault secrets enable -path=secret kv-v2
  
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
  
  # Save the token to a file that can be read by other scripts
  echo "$VAULT_TOKEN" > /root/vault-root-token.txt
  echo "$UNSEAL_KEY" > /root/vault-unseal-key.txt
  
  # Make token file readable
  chmod 644 /root/wordpress-token.txt
fi

# Indicate setup completion
echo "Vault setup completed at $(date)" > /root/vault-ready
echo "WordPress token: $(cat /root/wordpress-token.txt)" >> /root/vault-ready