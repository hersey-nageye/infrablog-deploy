variable "vpc_cidr" {
  type        = string
  description = "Cidr blocks for the VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for the public subnets"
}
variable "subnet_availability_zones" {
  type        = list(string)
  description = "List of availability zones for all subnets"
}


variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Cidr blocks for the private subnets"
}

# variable "name" {
#   type        = string
#   description = "Name tag used for identifying the resource in AWS"
# }

# variable "tags" {
#   type    = map(string)
#   default = {}
# }

variable "subnet_group_description" {
  type        = string
  description = "Description of the subnet group for database or application resources"
}

variable "subnet_group_name" {
  type        = string
  description = "The unique name assigned to the subnet group for resource grouping"
}

variable "environment" {
  type        = string
  description = "The environment for which the resources are being created, e.g., dev, staging, prod"
}

variable "project_name" {
  type        = string
  description = "The name of the project for which the resources are being created"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to be applied to all resources"
}
