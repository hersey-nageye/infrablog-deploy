resource "aws_security_group" "vault_sg" {
  name        = "vault-sg"
  description = "Security group for Vault instance"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-vault-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "vault_ssh" {
  security_group_id = aws_security_group.vault_sg.id
  cidr_ipv4         = "0.0.0.0/0" # Change this to your IP address later
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-vault-ssh-rule"
  })
}

resource "aws_vpc_security_group_ingress_rule" "vault_UI" {
  security_group_id = aws_security_group.vault_sg.id
  cidr_ipv4         = "0.0.0.0/0" # Change this to your IP address later
  from_port         = 8200
  ip_protocol       = "tcp"
  to_port           = 8200

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-vault-ui-rule"
  })
}

# Add rule to allow WordPress to access Vault
resource "aws_vpc_security_group_ingress_rule" "vault_from_wordpress" {
  security_group_id            = aws_security_group.vault_sg.id
  referenced_security_group_id = aws_security_group.wordpress_sg.id
  from_port                    = 8200
  ip_protocol                  = "tcp"
  to_port                      = 8200

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-vault-from-wordpress-rule"
  })
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.vault_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-vault-egress-rule"
    }
  )
}

# Create security group for WordPress (needed for the reference above)
resource "aws_security_group" "wordpress_sg" {
  name        = "wordpress-sg"
  description = "Security group for WordPress instance"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-wordpress-sg"
  })
}

data "aws_key_pair" "existing_key" {
  key_name = "terraform"
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-key-pair"
    }
  )
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = [var.ami_owner_id]
  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Generate a random password for better security
resource "random_password" "vault_wordpress_token" {
  length  = 32
  special = true
}

resource "aws_instance" "vault" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.vault_sg.id]
  key_name                    = data.aws_key_pair.existing_key.key_name
  associate_public_ip_address = true

  lifecycle {
    ignore_changes = [ami]
  }

  # Use the script content directly instead of templatefile for better control
  user_data = base64encode(templatefile("${path.module}/../../scripts/vault-user-data.sh", {
    db_user       = var.db_user
    db_pass       = var.db_pass
    VAULT_VERSION = "1.15.5"
  }))

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-vault"
    }
  )
}

# Use null_resource to wait for Vault to be ready and extract token
resource "null_resource" "wait_for_vault" {
  depends_on = [aws_instance.vault]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/Projects/.ssh/terraform-private-key.pem") # Adjust path as needed
    host        = aws_instance.vault.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for Vault setup to complete...'",
      "timeout 300 bash -c 'until [ -f /root/vault-ready ]; do sleep 5; done'",
      "echo 'Vault setup completed'"
    ]
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Extract the WordPress token from Vault instance
      scp -i ~/.ssh/terraform.pem -o StrictHostKeyChecking=no ubuntu@${aws_instance.vault.public_ip}:/root/wordpress-token.txt ./wordpress-token.txt || echo "default-token" > ./wordpress-token.txt
    EOT
  }
}
