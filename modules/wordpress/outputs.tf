output "wordpress_instance_id" {
  description = "Instance ID of the WordPress application"
  value       = aws_instance.wordpress.id

}

output "wordpress_public_ip" {
  description = "Public IP of the WordPress instance"
  value       = aws_instance.wordpress.public_ip

}
