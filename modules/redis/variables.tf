# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "active_active" {
  type        = bool
  description = "Flag for active-active configuation: true for active-active, false for standalone"
}

variable "kms_key_arn" {
  description = "The Amazon Resource Name of the KMS key which will be used by the Redis Elasticache replication group to encrypt data at rest."
  type        = string
}

variable "tfe_instance_sg" {
  description = "The identity of the security group attached to the TFE EC2 instance(s) which will be authorized to communicate with the Redis Elasticache replication group."
  type        = string
}

variable "network_id" {
  description = "The identity of the VPC in which the security group attached to the Redis Elasticache replication group will be deployed."
  type        = string
}

variable "network_subnets_private" {
  description = "A list of the identities of the private subnetworks in which the Redis Elasticache replication group will be deployed."
  type        = list(string)
}

variable "friendly_name_prefix" {
  type        = string
  description = "(Required) Friendly name prefix used for tagging and naming AWS resources."
}

variable "network_private_subnet_cidrs" {
  type        = list(string)
  description = "(Optional) List of private subnet CIDR ranges to create in VPC."
}

variable "redis_port" {
  type        = number
  description = "Set port for Redis. Defaults to 6379 default port"
}

variable "cache_size" {
  type        = string
  description = "Redis instance size."
}

variable "engine_version" {
  type        = string
  description = "Redis enginer version."
}

variable "parameter_group_name" {
  type        = string
  description = "Redis parameter group name."
}

# Security
variable "redis_encryption_in_transit" {
  type        = bool
  description = "Determine whether Redis traffic is encrypted in transit."
}

variable "redis_encryption_at_rest" {
  type        = bool
  description = "Determine whether Redis data is encrypted at rest."
}

variable "redis_use_password_auth" {
  type        = bool
  description = "Determine if a password is required for Redis."
}
