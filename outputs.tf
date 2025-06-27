
output "rendered_user_data" {
  value = templatefile("${path.module}/wordpress-user-data.sh", {
    DB_NAME     = var.db_name
    DB_USER     = var.db_user
    DB_PASSWORD = var.db_password
  })
  description = "The fully rendered user_data script for debugging."
  # Remove sensitive = true if you want to see the values in local output
  # You can add it back when you're done debugging.
  # sensitive   = true
}
