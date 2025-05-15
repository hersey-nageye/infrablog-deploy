module "vpc" {
  source                    = "./modules/vpc"
  vpc_cidrs                 = var.vpc_cidrs
  name_tag                  = var.name_tag
  subnet_availability_zones = var.subnet_availability_zones
  subnet_group_description  = var.subnet_group_description
  public_subnet_cidrs       = var.public_subnet_cidrs
  private_subnet_cidrs      = var.private_subnet_cidrs

}

module "vault" {
  source          = "./modules/vault"
  sg_name         = "vault-sg"
  vpc_id          = module.vpc.vpc_id
  name_tag        = var.name_tag
  subnet_id       = module.vpc.private_subnet_ids[0]
  key_name        = var.key_name
  public_key      = file(var.public_key_path)
  ami_name_filter = var.ami_name_filter
  ami_onwer_id    = var.ami_onwer_id
  sg_id           = module.bastion_sg.bastion_sg_id

}

module "wordpress_app" {
  source            = "./modules/wordpress"
  sg_name           = "wordpress-sg"
  wp_sg_description = var.wp_sg_description
  vpc_id            = module.vpc.vpc_id
  name_tag          = var.name_tag
  key_name          = var.key_name
  public_key        = file(var.public_key_path)
  ami_name_filter   = var.ami_name_filter
  ami_onwer_id      = var.ami_onwer_id
  subnet_id         = module.vpc.private_subnet_ids[1]
  sg_id             = module.bastion_sg.bastion_sg_id
}

module "rds" {
  source             = "./modules/rds"
  sg_name            = "rds-sg"
  rds_sg_description = var.rds_sg_description
  sg_id              = module.wordpress_app.wordpress_sg_id
  subnet_group_name  = var.subnet_group_name
  db_name            = var.db_name
  vpc_id             = module.vpc.vpc_id
  name_tag           = var.name_tag

}

module "bastion" {
  source            = "./modules/bastion"
  sg_name           = "bastion-sg"
  bt_sg_description = var.bt_sg_description
  vpc_id            = module.vpc.vpc_id
  key_name          = var.key_name
  public_key        = file(var.public_key_path)
  ami_name_filter   = var.ami_name_filter
  ami_onwer_id      = var.ami_onwer_id
  subnet_id         = module.vpc.public_subnet_id
  name_tag          = var.name_tag

}

module "route53" {
  source      = "./modules/route53"
  domain_name = var.domain_name
}


