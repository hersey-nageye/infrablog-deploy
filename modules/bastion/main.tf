# Security group for the Bastion server
resource "aws_security_group" "bastion_sg" {
  name        = var.sg_name
  description = var.sg_description
  vpc_id      = var.vpc_id

  tags = {
    Name = var.name
  }
}

# SSH inbound rule
resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  security_group_id = aws_security_group.bastion_sg.id
  cidr_ipv4         = "172.28.215.169"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Public key for accessing the Bastion instance
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

# EC2 instance Bastion server will run on
resource "aws_instance" "wordpress_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.wordpress_sg.id]
  key_name                    = aws_key_pair.ssh_access_key.id

  tags = {
    Name : var.name
  }
  lifecycle {
    ignore_changes = [associate_public_ip_address, ami]
  }
}

