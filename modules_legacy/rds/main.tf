# Security group for the RDS Instance
resource "aws_security_group" "rds_sg" {
  name        = var.name
  description = var.rds_sg_description
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-rds-sg-${var.environment}"
    }
  )
}

# Inbound rule to only allow traffic on port 3306 from Wordpress application
resource "aws_vpc_security_group_ingress_rule" "rds_3306" {
  security_group_id            = aws_security_group.rds_sg.id
  referenced_security_group_id = var.wordpress_sg_id # This is the security group ID of the Wordpress application
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-rds-3306-rule-${var.environment}"
    }
  )
}


# To generate random username
resource "random_string" "db_username" {
  length  = 8
  upper   = false
  special = false
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
  username             = "dbuser_${random_string.db_username.result}"
  password             = random_password.db_password.result
  skip_final_snapshot  = true
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-rds-${var.environment}"
    }
  )
}


