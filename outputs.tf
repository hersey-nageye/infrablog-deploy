
# outputs.tf in your root Terraform directory
output "rendered_user_data" {
  value = templatefile("${path.modules}/modules/wordpress/wordpress-user-data.sh", {
    DB_NAME     = var.db_name
    DB_USER     = var.db_user
    DB_PASSWORD = var.db_password
  })
  description = "The fully rendered user_data script for debugging purposes."
  # IMPORTANT: Remove 'sensitive = true' temporarily to see the actual values.
  # Remember to add it back once you're done debugging!
  #   sensitive = true
}
