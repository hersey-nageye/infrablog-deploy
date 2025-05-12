variable "subnet_group_name" {
  type        = string
  description = "subnet group name"
}

variable "db_name" {
  type        = string
  description = "Name of the database"
}

variable "sg_id" {
  type        = string
  description = "ID for the security group"
}

variable "sg_description" {
  type        = string
  description = "Security group description"
}

variable "sg_name" {
  type        = string
  description = "Name of the security group"
}

variable "vpc_id" {
  type        = string
  description = "ID for the VPC"
}

variable "name" {
  type        = string
  description = "Name for the resource tag"
}
