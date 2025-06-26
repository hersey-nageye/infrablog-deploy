# outputs.tf for vault module
output "vault_instance_id" {
  description = "ID of the Vault instance"
  value       = aws_instance.vault.id
}

output "vault_security_group_id" {
  description = "Security group ID of the Vault instance"
  value       = aws_security_group.vault_sg.id
}

output "vault_private_ip" {
  description = "Private IP for Vault instance"
  value       = aws_instance.vault.private_ip
}
