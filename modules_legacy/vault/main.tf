# Security group for the Vault Server
resource "aws_security_group" "vault_sg" {
  name        = var.name
  description = "SG for ${var.name}"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-vault-sg-${var.environment}"
    }
  )
}

# SSH inbound rule
resource "aws_vpc_security_group_ingress_rule" "vault_ssh" {
  security_group_id = aws_security_group.vault_sg.id
  cidr_ipv4         = var.ipv4_cidr # This is your IP address. Change this once Vault is correctly configured to the security group for the bastion host
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-vault-ssh-rule-${var.environment}"
    }
  )
}

# Inbound rule for Vault UI access
resource "aws_vpc_security_group_ingress_rule" "vault_UI" {
  security_group_id = aws_security_group.vault_sg.id
  cidr_ipv4         = var.ipv4_cidr
  from_port         = 8200
  ip_protocol       = "tcp"
  to_port           = 8200
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-vault-ui-rule-${var.environment}"
    }
  )
}

# Outbound rule for all traffic on all ports
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.vault_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-vault-egress-rule-${var.environment}"
    }
  )
}

# Data block to read existing key pair
data "aws_key_pair" "existing_key" {
  key_name = "terraform"
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-key-pair-${var.environment}"
    }
  )
}

# Data block to dynamically retrieve latest Ubuntu AMI for our instance
data "aws_ami" "ubuntu" {

  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [var.ami_onwer_id]
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-ubuntu-ami-${var.environment}"
    }
  )
}

# EC2 instance Vault Server will run on
resource "aws_instance" "vault_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.vault_sg.id]
  key_name               = data.aws_key_pair.existing_key.key_name
  user_data = templatefile("${path.module}/scripts/vault-user-data.sh.tpl", {
    vault_version = "1.15.5"         # Specify the Vault version you want to install
    rds_endpoint  = var.rds_endpoint # Endpoint for the RDS instance
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-vault-server-${var.environment}"
    }
  )
  lifecycle {
    ignore_changes = [associate_public_ip_address, ami]
  }
}


