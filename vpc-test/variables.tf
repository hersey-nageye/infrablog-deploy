variable "vpc_cidr" {
  type        = string
  description = "Cidr blocks for the VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for the public subnets"
}

variable "public_subnet_count" {
  type        = number
  description = "Number of public subnets to create"
}

variable "private_subnet_count" {
  type        = number
  description = "Number of private subnets to create"
  default     = 2

}
variable "public_subnet_azs" {
  type        = list(string)
  description = "The availability zones for the public subnets"
  default     = []
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Cidr blocks for the private subnets"
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_azs" {
  type        = list(string)
  description = "The availability zones for the subnets"
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}

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
  description = "The environment for which the resources are being created, e.g., dev, prod"
}

variable "project_name" {
  type        = string
  description = "The name of the project for which the resources are being created"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to be applied to all resources"
}

variable "env" {
  description = "Deployment environment"
  type        = string
  default     = "localstack"
}
