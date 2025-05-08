# Security group for the Wordpress server
resource "aws_security_group" "wordpress_sg" {
  name        = var.sg_name
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = var.name
  }
}

# SSH inbound rule
resource "aws_vpc_security_group_ingress_rule" "wordpress_ssh" {
  security_group_id = aws_security_group.vault
  cidr_ipv4         = "152.37.89.175" # Look at incorporating AWS system manager 
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Inbound rule for Vault UI access
resource "aws_vpc_security_group_ingress_rule" "vault_UI" {
  security_group_id = aws_security_group.vault_sg.id
  cidr_ipv4         = "152.37.89.175" # This is your IP address. Change this once Vault is correctly configured to the security group for the wordpress app
  from_port         = 8200
  ip_protocol       = "tcp"
  to_port           = 8200
}

# Outbound rule for all traffic on all ports
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.vault_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Public key for accessing the Vault instance
resource "aws_key_pair" "ssh_access_key" {
  key_name   = var.key_name
  public_key = var.public_key
}
