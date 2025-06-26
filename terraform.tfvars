# terraform.tfvars
project_name = "infra-deploy"

# Networking
vpc_cidr = "10.0.0.0/16"

public_subnet_cidrs = ["10.0.1.0/24"]

subnet_availability_zones = ["eu-west-2a"]

common_tags = {
  Project = "wordpress-project"
  Owner   = "Hersey Nageye"
}


# EC2
ami_owner_id    = "099720109477" # Canonical, Ubuntu AMIs
ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
instance_type   = "t2.micro"
