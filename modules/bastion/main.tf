# Security group for the Bastion server
resource "aws_security_group" "bastion_sg" {
  name        = var.name
  description = "SG for ${var.name}"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-bastion-sg-${var.environment}"
    }
  )
}

# SSH inbound rule
resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  security_group_id = aws_security_group.bastion_sg.id
  cidr_ipv4         = var.ipv4_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-bastion-ssh-rule-${var.environment}"
    }
  )
}

# Outbound rule for all traffic on all ports
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.bastion_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-bastion-egress-rule-${var.environment}"
    }
  )
}

# Data block to read existing key pair
data "aws_key_pair" "existing_key" {
  key_name = var.key_name
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

# EC2 instance Bastion server will run on
resource "aws_instance" "bastion_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  associate_public_ip_address = var.associate_public_ip
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  key_name                    = data.aws_key_pair.existing_key.key_name

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-bastion-server-${var.environment}"
    }
  )
  lifecycle {
    ignore_changes = [associate_public_ip_address, ami]
  }
}

