module "vpc" {
  source                    = "./modules/vpc"
  vpc_cidr                  = var.vpc_cidr
  public_subnet_cidrs       = var.public_subnet_cidrs
  subnet_availability_zones = var.subnet_availability_zones
  common_tags               = var.common_tags
  project_name              = var.project_name
}

module "wordpress" {
  source          = "./modules/wordpress"
  vpc_id          = module.vpc.vpc_id
  common_tags     = var.common_tags
  project_name    = var.project_name
  ami_owner_id    = var.ami_owner_id
  ami_name_filter = var.ami_name_filter
  instance_type   = var.instance_type
  subnet_id       = module.vpc.public_subnet_ids[0]
  db_name         = var.db_name
  db_password     = var.db_password
  db_user         = var.db_user
}
