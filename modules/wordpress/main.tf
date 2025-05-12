# Security group for the Wordpress application
resource "aws_security_group" "wordpress_sg" {
  name        = var.sg_name
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = var.name
  }
}

# SSH inbound rule
resource "aws_vpc_security_group_ingress_rule" "wordpress_ssh" {
  security_group_id = aws_security_group.wordpress_sg.id
  cidr_ipv4         = "0.0.0.0/0" # Change so that only traffic from the bastion server is accepted
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Inbound rule for HTTP access
resource "aws_vpc_security_group_ingress_rule" "wordpress_http" {
  security_group_id = aws_security_group.wordpress_sg.id
  cidr_ipv4         = "0.0.0.0/0" # Make this temporary and close once you've configured redirection to HTTPS
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# Inbound rule for HTTPS access
resource "aws_vpc_security_group_ingress_rule" "wordpress_https" {
  security_group_id = aws_security_group.wordpress_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

# Outbound rule for all traffic on all ports
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.wordpress_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Public key for accessing the Wordpress instance
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

# EC2 instance Wordpress application will run on
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

