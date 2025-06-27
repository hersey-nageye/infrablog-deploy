output "wordpress_security_group_id" {
  description = "value of the security group ID for the WordPress instance"
  value       = aws_security_group.wordpress_sg.id
}

output "wordpress_instance_id" {
  description = "ID of the WordPress instance"
  value       = aws_instance.wordpress.id

}

# outputs.tf in your root Terraform directory
output "rendered_user_data" {
  value = templatefile("${path.module}/wordpress-user-data.sh", {
    DB_NAME     = var.db_name
    DB_USER     = var.db_user
    DB_PASSWORD = var.db_password
  })
  description = "The fully rendered user_data script for debugging purposes."
  # IMPORTANT: Remove 'sensitive = true' temporarily to see the actual values.
  # Remember to add it back once you're done debugging!
  # sensitive = true
}
