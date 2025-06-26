variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created."
  type        = string
}

variable "common_tags" {
  description = "Common tags to be applied to the security group."
  type        = map(string)
  default     = {}
}
variable "project_name" {
  description = "The name of the project for tagging purposes."
  type        = string
}

variable "ami_owner_id" {
  description = "The AWS account ID of the AMI owner."
  type        = string
}

variable "ami_name_filter" {
  description = "The name filter for the AMI to be used."
  type        = string
}

variable "instance_type" {
  description = "The instance type for the vault server."
  type        = string

}

variable "subnet_id" {
  description = "The ID of the subnet where the vault server will be launched."
  type        = string

}

variable "jumpbox_sg_id" {
  description = "The ID of the security group for the jumpbox instance."
  type        = string

}

variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "db_username" {
  description = "Username of database"
  type        = string
}

variable "db_password" {
  description = "Password for database"
  type        = string
  sensitive   = true
}

variable "wp_vault_password" {
  description = "Password for wordpress isstance to access vault"
  type        = string
  sensitive   = true
}
