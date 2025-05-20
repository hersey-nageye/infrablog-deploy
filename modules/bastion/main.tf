# Security group for the Bastion server
resource "aws_security_group" "bastion_sg" {
  name        = var.name
  description = "SG for ${var.name}"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

# SSH inbound rule
resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  security_group_id = aws_security_group.bastion_sg.id
  cidr_ipv4         = var.ipv4_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Data block to read existing key pair
data "aws_key_pair" "existing_key" {
  key_name = "terraform"
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

# EC2 instance Bastion server will run on
resource "aws_instance" "wordpress_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  key_name                    = data.aws_key_pair.existing_key.key_name

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
  lifecycle {
    ignore_changes = [associate_public_ip_address, ami]
  }
}

