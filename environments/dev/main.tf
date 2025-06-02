module "vpc" {
  source                    = "../../modules/vpc"
  vpc_cidr                  = var.vpc_cidr
  public_subnet_cidrs       = var.public_subnet_cidrs
  subnet_availability_zones = var.subnet_availability_zones
  private_subnet_cidrs      = var.private_subnet_cidrs
  name                      = var.name
  subnet_group_description  = var.subnet_group_description
  subnet_group_name         = var.subnet_group_name
  environment               = var.environment
  project_name              = var.project_name
  common_tags               = var.common_tags

}

# module "vault" {
#   source          = "./modules/vault"
#   name            = "vault"
#   tags            = local.common_tags
#   vpc_id          = module.vpc.vpc_id
#   subnet_id       = module.vpc.private_subnet_ids[0]
#   ami_name_filter = var.ami_name_filter
#   ami_onwer_id    = var.ami_onwer_id
#   sg_id           = module.bastion.bastion_sg_id
#   ipv4_cidr       = var.ipv4_cidr
# }

# module "wordpress_app" {
#   source            = "./modules/wordpress"
#   name              = "wordpress"
#   wp_sg_description = var.wp_sg_description
#   vpc_id            = module.vpc.vpc_id
#   ami_name_filter   = var.ami_name_filter
#   ami_onwer_id      = var.ami_onwer_id
#   subnet_id         = module.vpc.private_subnet_ids[1]
#   sg_id             = module.bastion.bastion_sg_id
# }

# module "rds" {
#   source             = "./modules/rds"
#   name               = "rds"
#   tags               = local.common_tags
#   rds_sg_description = var.rds_sg_description
#   sg_id              = module.wordpress_app.wordpress_sg_id
#   subnet_group_name  = module.vpc.subnet_group_name
#   db_name            = var.db_name
#   vpc_id             = module.vpc.vpc_id
# }

# module "bastion" {
#   source            = "./modules/bastion"
#   name              = "bastion"
#   tags              = local.common_tags
#   bt_sg_description = var.bt_sg_description
#   vpc_id            = module.vpc.vpc_id
#   ami_name_filter   = var.ami_name_filter
#   ami_onwer_id      = var.ami_onwer_id
#   subnet_id         = module.vpc.public_subnet_id
#   ipv4_cidr         = var.ipv4_cidr

# }

# module "route53" {
#   source      = "./modules/route53"
#   domain_name = var.domain_name
# }


