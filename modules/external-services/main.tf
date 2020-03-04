### =================================================================== REQUIRED

variable "vpc_id" {
  type        = string
  description = "AWS VPC id to install into"
}

variable "install_id" {
  type        = string
  description = "Identifier for installation"
}

### =================================================================== OPTIONAL

variable "prefix" {
  type        = string
  description = "string to prefix all resources with "
  default     = ""
}

variable "rds_instance_class" {
  type        = string
  description = "instance class of the database"
  default     = "db.r5.large"
}

variable "rds_subnet_tags" {
  type        = map
  description = "tags to use to match subnets to use"
  default     = {}
}

variable "database_name" {
  type        = string
  description = "name of the initial database"
  default     = "tfe"
}

variable "database_username" {
  type        = string
  description = "username of the initial user"
  default     = "tfe"
}
