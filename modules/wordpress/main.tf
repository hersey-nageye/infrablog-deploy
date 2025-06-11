# Security group for the Wordpress application
resource "aws_security_group" "wordpress_sg" {
  name        = var.name
  description = "SG for ${var.name}"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-wordpress-sg-${var.environment}"
    }
  )
}

# SSH inbound rule
resource "aws_vpc_security_group_ingress_rule" "wordpress_ssh" {
  security_group_id = aws_security_group.wordpress_sg.id
  cidr_ipv4         = var.ipv4_cidr # This is your IP address. Change this once the Wordpress app is correctly configured to the security group for the bastion host
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-wordpress-ssh-rule-${var.environment}"
    }
  )
}

# Inbound rule for HTTP access
resource "aws_vpc_security_group_ingress_rule" "wordpress_http" {
  security_group_id = aws_security_group.wordpress_sg.id
  cidr_ipv4         = var.ipv4_cidr
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-wordpress-http-rule-${var.environment}"
    }
  )
}

# Inbound rule for HTTPS access
resource "aws_vpc_security_group_ingress_rule" "wordpress_https" {
  security_group_id = aws_security_group.wordpress_sg.id
  cidr_ipv4         = var.ipv4_cidr
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-wordpress-https-rule-${var.environment}"
    }
  )
}

# Outbound rule for all traffic on all ports
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.wordpress_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-wordpress-egress-rule-${var.environment}"
    }
  )
}

# Static IP address for the Wordpress application
# resource "aws_eip" "wordpress_eip" {
#   instance = aws_instance.wordpress_server.id
# }

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
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.wordpress_sg.id]
  key_name                    = data.aws_key_pair.existing_key.key_name
  user_data = templatefile("${path.module}/scripts/wordpress-user-data.sh.tpl", {
    vault_ip = var.vault_private_ip
  })

  user_data_replace_on_change = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-wordpress-server-${var.environment}"
    }
  )
  lifecycle {
    ignore_changes = [associate_public_ip_address, ami]
  }
}

