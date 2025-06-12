variable "subnet_group_name" {
  type        = string
  description = "subnet group name"
}

variable "db_name" {
  type        = string
  description = "Name of the database"
}

variable "rds_sg_description" {
  type        = string
  description = "Security group description"
}

variable "name" {
  type        = string
  description = "Name tag for the resource"
}

variable "vpc_id" {
  type        = string
  description = "ID for the VPC"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to be applied to all resources"

}

variable "environment" {
  type        = string
  description = "Environment for the resources (e.g., dev, prod)"

}

variable "project_name" {
  type        = string
  description = "Project name for the resources"

}

variable "wordpress_sg_id" {
  type        = string
  description = "Security group ID for the WordPress instance"

}
