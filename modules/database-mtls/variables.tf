variable "domain_name" {
  description = "The name of the Route 53 Hosted Zone in which a record will be created."
  type        = string
}

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

variable "network_private_subnet_cidrs" {
  type        = list(string)
  description = "(Optional) List of private subnet CIDR ranges to create in VPC."
}

variable "postgres_ca_certificate_secret_id" {
  type = string
}

variable "postgres_client_certificate_secret_id" {
  type = string
}

variable "postgres_client_key_secret_id" {
  type = string
}

variable "aws_iam_instance_profile" {
  description = "The name of the IAM instance profile to be associated with the TFE EC2 instance(s)."
  type        = string
}
