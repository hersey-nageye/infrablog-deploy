# terraform.tfvars
project_name = "infra-deploy"
environment  = "dev"

# Networking
vpc_cidr = "10.0.0.0/16"

public_subnet_cidrs  = ["10.0.1.0/24"]
private_subnet_cidrs = ["10.0.2.0/24", "10.0.3.0/24"]

subnet_availability_zones = ["eu-west-2a", "eu-west-2b"]

name                     = "dev-vpc"
subnet_group_description = "Subnet group for dev environment"
subnet_group_name        = "dev-subnet-group"

common_tags = {
  Environment = "dev"
  Project     = "wordpress-project"
  Owner       = "Hersey Nageye"
}


# # Security groups
# wp_sg_description  = "Inbound: SSH (22) from bastion-server-sg, HTTP (80) and HTTPS (443) from 0.0.0.0/0. Outbound: All."
# rds_sg_description = "Inbound: MySQL traffic (3306) from wordpress-sg. Outbound: All."
# bt_sg_description  = "Inbound: SSH (22) from from 0.0.0.0/0. Outbound: All"

# # Domain and Routing
# domain_name = "drhersey.org"


# # Database
# db_name = "wordpressdb"


# # EC2 AMI
# ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
# ami_onwer_id    = "099720109477"

