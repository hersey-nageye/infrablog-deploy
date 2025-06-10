# terraform.tfvars
project_name = "infra-deploy"
environment  = "dev"

# Networking
vpc_cidr = "10.0.0.0/16"

public_subnet_cidrs  = ["10.0.1.0/24"]
private_subnet_cidrs = ["10.0.2.0/24", "10.0.3.0/24"]

subnet_availability_zones = ["eu-west-2a", "eu-west-2b"]

subnet_group_description = "Subnet group for dev environment"
subnet_group_name        = "dev-subnet-group"
ipv4_cidr                = "0.0.0.0/0" # Source IP address for inbound SSH access to the bastion server

common_tags = {
  Environment = "dev"
  Project     = "wordpress-project"
  Owner       = "Hersey Nageye"
}


# # Security groups
# wp_sg_description  = "Inbound: SSH (22) from bastion-server-sg, HTTP (80) and HTTPS (443) from 0.0.0.0/0. Outbound: All."
# rds_sg_description = "Inbound: MySQL traffic (3306) from wordpress-sg. Outbound: All."
# bt_sg_description = "Inbound: SSH (22) from from 0.0.0.0/0. Outbound: All"
bastion_name = "bastion"   # Name tag used for identifying the resource in AWS
vault_name   = "vault"     # Name tag used for identifying the resource in AWS
wp_name      = "wordpress" # Name tag used for identifying the resource in AWS


# EC2 AMI
ami_name_filter     = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
ami_onwer_id        = "099720109477"
instance_type       = "t2.micro"
associate_public_ip = true
key_name            = "terraform"
