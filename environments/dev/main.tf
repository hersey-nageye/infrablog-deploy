module "vpc" {
  source                    = "../../modules/vpc"
  vpc_cidr                  = var.vpc_cidr
  public_subnet_cidrs       = var.public_subnet_cidrs
  subnet_availability_zones = var.subnet_availability_zones
  private_subnet_cidrs      = var.private_subnet_cidrs
  subnet_group_description  = var.subnet_group_description
  subnet_group_name         = var.subnet_group_name
  environment               = var.environment
  project_name              = var.project_name
  common_tags               = var.common_tags

}

module "bastion" {
  source              = "../../modules/bastion"
  name                = var.bastion_name
  vpc_id              = module.vpc.vpc_id
  ami_name_filter     = var.ami_name_filter
  ami_onwer_id        = var.ami_onwer_id
  subnet_id           = module.vpc.public_subnet_id
  ipv4_cidr           = var.ipv4_cidr
  instance_type       = var.instance_type
  associate_public_ip = var.associate_public_ip
  key_name            = var.key_name
  environment         = var.environment
  project_name        = var.project_name
  common_tags         = var.common_tags

}

module "vault" {
  source          = "../../modules/vault"
  vpc_id          = module.vpc.vpc_id
  subnet_id       = module.vpc.public_subnet_id
  name            = var.vault_name
  ami_name_filter = var.ami_name_filter
  ami_onwer_id    = var.ami_onwer_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  ipv4_cidr       = var.ipv4_cidr
  environment     = var.environment
  project_name    = var.project_name
  common_tags     = var.common_tags
  sg_id           = module.bastion.bastion_sg_id
  wordpress_sg_id = module.wordpress.wordpress_sg_id
}

module "wordpress" {
  source           = "../../modules/wordpress"
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.public_subnet_id
  ami_name_filter  = var.ami_name_filter
  ami_onwer_id     = var.ami_onwer_id
  instance_type    = var.instance_type
  ipv4_cidr        = var.ipv4_cidr
  environment      = var.environment
  project_name     = var.project_name
  common_tags      = var.common_tags
  sg_id            = module.bastion.bastion_sg_id
  name             = var.wp_name
  vault_private_ip = module.vault.vault_private_ip
}

