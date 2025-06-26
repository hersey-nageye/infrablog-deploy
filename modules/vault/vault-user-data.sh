#!/bin/bash

# Install Vault
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt update && apt install vault -y

# Create vault user and directories
useradd --system --home /etc/vault.d --shell /bin/false vault
mkdir -p /opt/vault/data
chown -R vault:vault /opt/vault/data
chmod 755 /opt/vault/data

# Create Vault configuration
cat > /etc/vault.d/vault.hcl << 'EOF'
ui = true
storage "file" {
  path = "/opt/vault/data"
}
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}
api_addr = "http://0.0.0.0:8200"
cluster_addr = "http://0.0.0.0:8201"
EOF

# Create systemd service
cat > /etc/systemd/system/vault.service << 'EOF'
[Unit]
Description=HashiCorp Vault
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault.d/vault.hcl

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
NoNewPrivileges=yes
ExecStart=/usr/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
StartLimitBurst=3
StartLimitIntervalSec=60
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# Set permissions
chown -R vault:vault /etc/vault.d
chmod 640 /etc/vault.d/vault.hcl

# Enable and start Vault
systemctl daemon-reload
systemctl enable vault
systemctl start vault

# Wait for Vault to start
sleep 10

# Set Vault address
export VAULT_ADDR='http://127.0.0.1:8200'
echo 'export VAULT_ADDR="http://127.0.0.1:8200"' >> /root/.bashrc

# Initialize Vault
vault operator init -key-shares=1 -key-threshold=1 > /root/vault-keys.txt

# Extract unseal key and root token
UNSEAL_KEY=$(grep 'Unseal Key 1:' /root/vault-keys.txt | awk '{print $4}')
ROOT_TOKEN=$(grep 'Initial Root Token:' /root/vault-keys.txt | awk '{print $4}')

# Unseal Vault
vault operator unseal $UNSEAL_KEY

# Login with root token
vault auth $ROOT_TOKEN

# Store DB credentials in Vault
vault kv put secret/wordpress \
  db_name="${db_name}" \
  db_user="${db_username}" \
  db_password="${db_password}"

# Create a policy for WordPress
vault policy write wordpress-policy - << 'EOF'
path "secret/data/wordpress" {
  capabilities = ["read"]
}
EOF

# Enable userpass auth method
vault auth enable userpass

# Create WordPress user
vault write auth/userpass/users/wordpress \
  password="${wp_vault_password}" \
  policies="wordpress-policy"

echo "Vault setup complete!"
echo "Root token: $ROOT_TOKEN"
echo "WordPress vault password: ${wp_vault_password}"