output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}

output "db_username" {
  value = random_string.db_username.result
}
