variable "vpc_cidrs" {
  type        = string
  description = "Cidr block for the VPC"
}

variable "public_subnet_cidrs" {
  type        = string
  description = "value"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Cidr blocks for the private subnets"
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "subnet_availability_zones" {
  type        = list(string)
  description = "The availability zones for the subnets"
}

variable "name_tag" {
  type        = string
  description = "Name tag used for the resource"
}

variable "subnet_group_description" {
  type        = string
  description = "description of the subnet group"
}
