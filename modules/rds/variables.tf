variable "vpc_id" {
  description = "CIDR block for the VPC"
  type        = string

}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)

}

variable "project_name" {
  description = "Name of the project, used for tagging resources"
  type        = string

}

variable "wordpress_sg_id" {
  description = "Security group ID for the WordPress instance"
  type        = string

}

variable "db_name" {
  description = "Name of the RDS database"
  type        = string

}

variable "subnet_group_name" {
  description = "Name for the RDS subnet group"
  type        = string

}

variable "db_name" {
  description = "Name of the RDS database"
  type        = string

}
