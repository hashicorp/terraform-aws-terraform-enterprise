# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "aurora_db_password" {
  default     = "hashicorp"
  type        = string
  description = "PostgreSQL instance username. No special characters."
}

variable "aurora_db_username" {
  type        = string
  description = "PostgreSQL instance username. No special characters."

  validation {
    condition     = can(regex("^[a-zA-Z0-9]+$", var.aurora_db_username))
    error_message = "The db_name must only contain alphanumeric characters."
  }
}

variable "aurora_cluster_instance_replica_count" {
  type        = number
  default     = "0"
  description = "Number of extra cluster instances to create. Should be 0 if `aurora_cluster_instance_enable_single` is set to `true`."
}

variable "aurora_cluster_instance_enable_single" {
  type        = bool
  default     = true
  description = "Creates a single rds cluster instance."
}

variable "engine_version" {
  type        = string
  description = "PostgreSQL version."
  default     = "16.2"
}

variable "friendly_name_prefix" {
  type        = string
  description = "(Required) Friendly name prefix used for tagging and naming AWS resources."
}

variable "db_backup_retention" {
  type        = number
  description = "The days to retain backups for. Must be between 0 and 35."
  default     = 1
}

variable "db_backup_window" {
  type        = string
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled."
  default     = null
}

variable "db_name" {
  type        = string
  description = "PostgreSQL instance name. No special characters."

  validation {
    condition     = can(regex("^[a-zA-Z0-9]+$", var.db_name))
    error_message = "The db_name must only contain alphanumeric characters."
  }
}

variable "db_parameters" {
  type        = string
  description = "PostgreSQL server parameters for the connection URI. Used to configure the PostgreSQL connection (e.g. sslmode=require)."
}

variable "db_size" {
  type        = string
  default     = "db.r5.xlarge"
  description = "PostgreSQL instance size."
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. When specifying `kms_key_id`, `storage_encrypted` needs to be set to `true`."
  type        = string
  default     = null
}

variable "preferred_maintenance_window" {
  description = "The weekly time range during which system maintenance can occur, in (UTC)"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "network_id" {
  description = "The identity of the VPC in which the security group attached to the PostgreSQL RDS instance will be deployed."
  type        = string
}

variable "network_private_subnet_cidrs" {
  type        = list(string)
  description = "(Optional) List of private subnet CIDR ranges to create in VPC."
  default     = ["10.0.32.0/20", "10.0.48.0/20", "10.0.112.0/20"]
}

variable "network_subnets_private" {
  description = <<-EOD
  A list of the identities of the private subnetworks in which the PostgreSQL RDS instance will be deployed.
  EOD
  type        = list(string)

  default = null
}

variable "tfe_instance_sg" {
  description = <<-EOD
  The identity of the security group attached to the TFE EC2 instance(s), which will be authorized for communication with the PostgreSQL RDS instance.
  EOD
  type        = string
  default     = null
}
