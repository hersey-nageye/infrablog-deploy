output "wordpress_security_group_id" {
  description = "value of the security group ID for the WordPress instance"
  value       = aws_security_group.wordpress_sg.id
}

output "wordpress_instance_id" {
  description = "ID of the WordPress instance"
  value       = aws_instance.wordpress.id

}

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
