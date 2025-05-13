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
  sg_name         = var.sg_name
  vpc_id          = module.vpc.vpc_id
  name_tag        = var.name_tag
  subnet_id       = module.vpc.private_subnet_ids[0]
  key_name        = var.key_name
  public_key      = file(var.public_key_path)
  ami_name_filter = var.ami_name_filter
  ami_onwer_id    = var.ami_onwer_id

}

