variable "db_name" {
  type        = string
  description = "PostgreSQL instance name. No special characters."
}

variable "db_username" {
  type        = string
  description = "PostgreSQL instance username. No special characters."
}

variable "db_parameters" {
  type        = string
  description = "PostgreSQL server parameters for the connection URI. Used to configure the PostgreSQL connection (e.g. sslmode=require)."
}
variable "network_id" {
  description = "The identity of the VPC in which the security group attached to the PostgreSQL RDS instance will be deployed."
  type        = string
}

variable "friendly_name_prefix" {
  type        = string
  description = "(Required) Friendly name prefix used for tagging and naming AWS resources."
}
