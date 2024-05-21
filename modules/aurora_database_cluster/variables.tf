# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "network_id" {
  description = "The identity of the VPC in which the security group attached to the PostgreSQL RDS instance will be deployed."
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

variable "db_size" {
  type        = string
  default     = "db.r5.xlarge"
  description = "PostgreSQL instance size."
}

variable "db_backup_retention" {
  type        = number
  description = "The days to retain backups for. Must be between 0 and 35"
  default     = 0
}

variable "db_backup_window" {
  type        = string
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled"
  default     = null
}

variable "db_parameters" {
  type        = string
  description = "PostgreSQL server parameters for the connection URI. Used to configure the PostgreSQL connection (e.g. sslmode=require)."
}

variable "engine_version" {
  type        = string
  description = "PostgreSQL version."
  default     = "16.2"
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

variable "friendly_name_prefix" {
  type        = string
  description = "(Required) Friendly name prefix used for tagging and naming AWS resources."
}

variable "network_private_subnet_cidrs" {
  type        = list(string)
  description = "(Optional) List of private subnet CIDR ranges to create in VPC."
  default     = ["10.0.32.0/20", "10.0.48.0/20"]
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. When specifying `kms_key_id`, `storage_encrypted` needs to be set to `true`"
  type        = string
  default     = null
}

variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created if automated backups are enabled using the `backup_retention_period` parameter. Time in UTC"
  type        = string
  default     = "02:00-03:00"
}

variable "preferred_maintenance_window" {
  description = "The weekly time range during which system maintenance can occur, in (UTC)"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "cluster_members" {
  description = "List of RDS Instances that are a part of this cluster"
  type        = list(string)
  default     = null
}

variable "replica_count" {
  type        = string
  default     = "1"
  description = "Number of reader nodes to create.  If `replica_scale_enable` is `true`, the value of `replica_scale_min` is used instead."
}

variable "single_instance_enabled" {
  type        = string
  default     = true
  description = "Whether the database resources should be created"
}
