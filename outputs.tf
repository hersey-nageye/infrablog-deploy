
output "vault_url" {
  value = module.vault.vault_url
}

output "wordpress_url" {
  value = "http://${module.wordpress.wordpress_public_ip}"
}
