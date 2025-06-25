# outputs.tf for vault module
output "vault_instance_id" {
  description = "ID of the Vault instance"
  value       = aws_instance.vault.id
}

output "vault_public_ip" {
  description = "Public IP of the Vault instance"
  value       = aws_instance.vault.public_ip
}

output "vault_private_ip" {
  description = "Private IP of the Vault instance"
  value       = aws_instance.vault.private_ip
}

output "vault_security_group_id" {
  description = "Security group ID of the Vault instance"
  value       = aws_security_group.vault_sg.id
}

output "wordpress_security_group_id" {
  description = "Security group ID for WordPress instance"
  value       = aws_security_group.wordpress_sg.id
}

output "vault_ready_trigger" {
  description = "Dependency trigger to ensure Vault is ready"
  value       = null_resource.wait_for_vault.id
}

output "vault_url" {
  description = "URL to access Vault UI"
  value       = "http://${aws_instance.vault.public_ip}:8200"
}
