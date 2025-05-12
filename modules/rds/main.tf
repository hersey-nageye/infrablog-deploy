# Security group for the RDS Instance
resource "aws_security_group" "rds_sg" {
  name        = var.sg_name
  description = var.sg_description
  vpc_id      = var.vpc_id

  tags = {
    Name = var.name
  }
}

# Inbound rule to only allow traffic on port 3306 from Wordpress application
resource "aws_vpc_security_group_ingress_rule" "wordpress_ssh" {
  security_group_id            = aws_security_group.rds_sg.id
  referenced_security_group_id = var.sg_id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}


# To generate random username
resource "random_pet" "db_username" {
  length = 2
}

# To generate random password
resource "random_password" "db_password" {
  length           = 16
  override_special = "_!%^"
  special          = true
}

# MYSQL database to be configured with wordpress application
resource "aws_db_instance" "database" {
  allocated_storage    = 20
  db_name              = var.db_name
  db_subnet_group_name = var.subnet_group_name
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = random_pet.db_username.id
  password             = random_password.db_password.result
  skip_final_snapshot  = true
}


