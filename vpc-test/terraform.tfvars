project_name         = "infra-deploy"
environment          = "dev"
vpc_cidr             = "10.0.0.0/16"
public_subnet_count  = 1
private_subnet_count = 2

public_subnet_cidrs  = ["10.0.1.0/24"]
private_subnet_cidrs = ["10.0.2.0/24", "10.0.3.0/24"]

public_subnet_azs  = ["us-east-1a"]
private_subnet_azs = ["us-east-1a"]

subnet_group_name        = "infra-deploy-db-subnet-group"
subnet_group_description = "Subnet group for RDS"

common_tags = {
  Owner       = "dev-team"
  Department  = "Engineering"
  Environment = "dev"
}
