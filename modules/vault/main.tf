
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
  cidr_ipv4         = "0.0.0.0/0" # Change this to your IP address for SSH access
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-vault-ssh-rule"
  })

}

resource "aws_vpc_security_group_ingress_rule" "vault_UI" {
  security_group_id = aws_security_group.vault_sg.id
  cidr_ipv4         = "0.0.0.0/0" # Change this to your IP address for Vault UI access
  from_port         = 8200
  ip_protocol       = "tcp"
  to_port           = 8200

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-vault-ui-rule"
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

# Data block to read existing key pair
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

resource "aws_instance" "vault" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.vault_sg.id]
  key_name               = data.aws_key_pair.existing_key.key_name
  lifecycle {
    ignore_changes = [associate_public_ip, ami]
  }

  user_data = templatefile("${path.module}/../../user_data/vault-user-data.sh.tpl", {
    db_user = var.db_user,
    db_pass = var.db_pass,
    db_host = var.db_host
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-vault"
    }
  )
}
