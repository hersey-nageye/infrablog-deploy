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

variable "rds_sg_description" {
  type        = string
  description = "Security group description"
}

variable "name" {
  type        = string
  description = "Name tag for the resource"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vpc_id" {
  type        = string
  description = "ID for the VPC"
}
