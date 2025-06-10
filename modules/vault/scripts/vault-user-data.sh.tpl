#!/bin/bash

set -e

# Install dependencies
apt-get update && apt-get install -y unzip curl jq

# Download and install Vault
VAULT_VERSION="${vault_version}"
cd /tmp
curl -O https://releases.hashicorp.com/vault/${vault_version}/vault_${vault_version}_linux_amd64.zip
unzip vault_${vault_version}_linux_amd64.zip
mv vault /usr/local/bin/
chmod +x /usr/local/bin/vault

# Create Vault user and directories
useradd --system --home /etc/vault.d --shell /bin/false vault
mkdir -p /etc/vault.d /opt/vault/data
chown -R vault:vault /etc/vault.d /opt/vault

# Vault config
cat <<EOF > /etc/vault.d/vault.hcl
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

storage "file" {
  path = "/opt/vault/data"
}

ui = true
EOF
chown vault:vault /etc/vault.d/vault.hcl

# Create systemd service
cat <<EOF > /etc/systemd/system/vault.service
[Unit]
Description=Vault
Requires=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP \$MAINPID
Restart=on-failure
User=vault
Group=vault
LimitNOFILE=65536
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
AmbientCapabilities=CAP_IPC_LOCK

[Install]
WantedBy=multi-user.target
EOF

# Start Vault
systemctl daemon-reload
systemctl enable vault
systemctl start vault
sleep 5

# Initialize & unseal Vault if needed
export VAULT_ADDR="http://127.0.1:8200"

if ! vault status | grep -q "Initialized.*true"; then
  vault operator init -key-shares=1 -key-threshold=1 -format=json > /root/init.json
  UNSEAL_KEY=$(jq -r .unseal_keys_b64[0] /root/init.json)
  ROOT_TOKEN=$(jq -r .root_token /root/init.json)

  vault operator unseal "$UNSEAL_KEY"
  export VAULT_TOKEN="$ROOT_TOKEN"

  # Load sample secrets (for WordPress)
  vault kv put secret/wordpress DB_USER=wp_user DB_PASS=wp_pass
  vault kv put secret/rds DB_USER=rds_user DB_PASS=rds_pass
fi
