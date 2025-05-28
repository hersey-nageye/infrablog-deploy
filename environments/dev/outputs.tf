output "db_password" {
  value     = module.rds.db_password
  sensitive = true
}
