# Security group for the WordPress EC2 instance
resource "aws_security_group" "wordpress_sg" {
  name        = "wordpress-sg"
  description = "Security group for WordPress instance"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-wordpress-sg"
  })
}

# Ingress rule to allow SSH access to the WordPress instance
resource "aws_vpc_security_group_ingress_rule" "wordpress_ssh" {
  security_group_id = aws_security_group.wordpress_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-wordpress-ssh-rule"
  })
}

# Ingress rule to allow HTTP traffic to the WordPress instance
resource "aws_vpc_security_group_ingress_rule" "wordpress_http" {
  security_group_id = aws_security_group.wordpress_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-wordpress-http-rule"
  })
}

# Egress rule to allow all outbound traffic from the WordPress instance
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.wordpress_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-wordpress-egress-rule"
    }
  )
}

# Data source to retrieve an existing EC2 key pair
data "aws_key_pair" "existing_key" {
  key_name = "terraform"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-key-pair"
    }
  )
}

# Data source to fetch the most recent Ubuntu AMI matching filter criteria
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

# EC2 instance resource for hosting the WordPress application
resource "aws_instance" "wordpress" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.wordpress_sg.id]
  key_name                    = data.aws_key_pair.existing_key.key_name
  associate_public_ip_address = true

  lifecycle {
    ignore_changes = [ami]
  }

  user_data = templatefile("${path.module}/wordpress-user-data.sh", {
    DB_NAME     = var.db_name
    DB_USER     = var.db_user
    DB_PASSWORD = var.db_password
  })

  user_data_replace_on_change = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-wordpress-instance"
    }
  )
}

