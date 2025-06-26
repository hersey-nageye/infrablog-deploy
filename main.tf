module "vpc" {
  source                    = "./modules/vpc"
  vpc_cidr                  = var.vpc_cidr
  public_subnet_cidrs       = var.public_subnet_cidrs
  private_subnet_cidrs      = var.private_subnet_cidrs
  subnet_availability_zones = var.subnet_availability_zones
  common_tags               = var.common_tags
  project_name              = var.project_name
}

module "jumpbox" {
  source          = "./modules/jumpbox"
  vpc_id          = module.vpc.vpc_id
  common_tags     = var.common_tags
  project_name    = var.project_name
  ami_owner_id    = var.ami_owner_id
  ami_name_filter = var.ami_name_filter
  instance_type   = var.instance_type
  subnet_id       = module.vpc.public_subnet_ids[0] # Assuming you want to deploy in the first public subnet

}

module "vault" {
  source            = "./modules/vault"
  vpc_id            = module.vpc.vpc_id
  common_tags       = var.common_tags
  project_name      = var.project_name
  ami_owner_id      = var.ami_owner_id
  ami_name_filter   = var.ami_name_filter
  instance_type     = var.instance_type
  subnet_id         = module.vpc.public_subnet_ids[0] # Assuming you want to deploy in the first private subnet
  jumpbox_sg_id     = module.jumpbox.jumpbox_security_group_id
  db_name           = var.db_name
  db_password       = var.db_password
  db_username       = var.db_username
  wp_vault_password = var.wp_vault_password
}

module "wordpress" {
  source            = "./modules/wordpress"
  vpc_id            = module.vpc.vpc_id
  common_tags       = var.common_tags
  project_name      = var.project_name
  ami_owner_id      = var.ami_owner_id
  ami_name_filter   = var.ami_name_filter
  instance_type     = var.instance_type
  subnet_id         = module.vpc.public_subnet_ids[0] # Assuming you want to deploy in the first public subnet
  db_name           = var.db_name
  db_username       = var.db_password
  db_password       = var.db_password
  wp_admin_user     = var.wp_admin_user
  wp_admin_password = var.wp_admin_password
  wp_admin_email    = var.wp_admin_email
  vault_private_ip  = module.vault.vault_private_ip
  wp_vault_password = var.wp_vault_password
}
