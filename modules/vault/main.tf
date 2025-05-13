# Security group for the Vault Server
resource "aws_security_group" "vault_sg" {
  name        = var.sg_name
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = var.name_tag
  }
}

# SSH inbound rule
resource "aws_vpc_security_group_ingress_rule" "vault_ssh" {
  security_group_id            = aws_security_group.vault_sg.id
  referenced_security_group_id = var.sg_id # Denotes Bastion sg id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

# Inbound rule for Vault UI access
resource "aws_vpc_security_group_ingress_rule" "vault_UI" {
  security_group_id = aws_security_group.vault_sg.id
  cidr_ipv4         = "152.37.89.175" # This is your IP address. Change this once Vault is correctly configured to the security group for the wordpress app
  from_port         = 8200
  ip_protocol       = "tcp"
  to_port           = 8200
}

# Outbound rule for all traffic on all ports
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.vault_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Public key for accessing the Vault instance
resource "aws_key_pair" "ssh_access_key" {
  key_name   = var.key_name
  public_key = var.public_key
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
}

# EC2 instance Vault Server will run on
resource "aws_instance" "vault_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.sg_id.id]
  key_name                    = aws_key_pair.ssh_access_key.key_name

  tags = {
    Name : var.name_tag
  }
  lifecycle {
    ignore_changes = [associate_public_ip_address, ami]
  }
}


