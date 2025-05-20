# Security group for the Wordpress application
resource "aws_security_group" "wordpress_sg" {
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
resource "aws_vpc_security_group_ingress_rule" "wordpress_ssh" {
  security_group_id            = aws_security_group.wordpress_sg.id
  referenced_security_group_id = var.sg_id # Denotes Bastion SG ID
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
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

resource "aws_eip" "wordpress_eip" {
  instance = aws_instance.wordpress_server.id
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

# EC2 instance Wordpress application will run on
resource "aws_instance" "wordpress_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.wordpress_sg.id]
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

