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
  description = "PostgreSQL instance size."
}

variable "db_backup_retention" {
  type        = number
  description = "The days to retain backups for. Must be between 0 and 35"
}

variable "db_backup_window" {
  type        = string
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled"
}

variable "db_parameters" {
  type        = string
  description = "PostgreSQL server parameters for the connection URI. Used to configure the PostgreSQL connection (e.g. sslmode=require)."
}

variable "engine_version" {
  type        = string
  description = "PostgreSQL version."
}

variable "network_subnets_private" {
  description = "A list of the identities of the private subnetworks in which the PostgreSQL RDS instance will be deployed."
  type        = list(string)
}

variable "tfe_instance_sg" {
  description = "The identity of the security group attached to the TFE EC2 instance(s), which will be authorized for communication with the PostgreSQL RDS instance."
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

variable "kms_key_arn" {
  description = "The Amazon Resource Name of the KMS key which will be used by the Redis Elasticache replication group to encrypt data at rest."
  type        = string
}
