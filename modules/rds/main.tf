resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  vpc_id      = var.vpc_id
  description = "Allow DB access from WordPress"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-rds-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "wp_to_rds" {
  security_group_id            = aws_security_group.rds_sg.id
  referenced_security_group_id = var.wordpress_sg_id # This is the security group ID of the WordPress application
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-wp_to_rds-rule"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "vault_to_rds" {
  security_group_id            = aws_security_group.rds_sg.id
  referenced_security_group_id = var.vault_sg_id # This is the security group ID of the WordPress application
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-vault_to_rds-rule"
    }
  )
}

resource "aws_db_instance" "database" {
  allocated_storage      = 20
  db_name                = var.db_name
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = var.db_user
  password               = var.db_pass
  db_subnet_group_name   = var.subnet_group_name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-database"
    }
  )
}
