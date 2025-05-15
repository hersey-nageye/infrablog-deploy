# terraform.tfvars

name_tag = "wordpress-project"

# Networking
vpc_cidrs                 = "value"
subnet_availability_zones = ["eu-west-1", "eu-west-2"]
subnet_group_description  = "Subnet group for RDS deployment"
public_subnet_cidrs       = "10.0.1.0/24"
private_subnet_cidrs      = ["10.0.2.0/24", "10.0.3.0/24"]
subnet_group_name         = "rds-subnet-group"

# Security groups
wp_sg_description  = "Inbound: SSH (22) from bastion-server-sg, HTTP (80) and HTTPS (443) from 0.0.0.0/0. Outbound: All."
rds_sg_description = "Inbound: MySQL traffic (3306) from wordpress-sg. Outbound: All."
bt_sg_description  = "Inbound: SSH (22) from from 0.0.0.0/0. Outbound: All"

# Domain and Routing
domain_name = "drhersey.org"


# Database
db_name = "wordpress-db"


# SSH
key_name        = "terraform"
public_key_path = "~/Projects/.ssh/terraform-key.pub"

# EC2 AMI
ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
ami_onwer_id    = "099720109477"

