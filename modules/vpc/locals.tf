locals {
  is_dev   = var.environment == "dev"
  is_prod  = var.environment == "prod"
  is_stage = var.environment == "staging"

  public_subnet_count  = local.is_dev ? 1 : length(var.subnet_availability_zones)
  private_subnet_count = local.is_dev ? 2 : length(var.subnet_availability_zones)
  nat_gateway_count    = local.is_dev ? 0 : length(var.subnet_availability_zones)
}
