# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "existing_iam_instance_profile_name" {
  description = "The IAM instance profile to be attached to the PostgreSQL EC2 instance. Leave the value null to create a new one."
  type        = string
  default     = null
}

variable "existing_iam_instance_role_name" {
  type        = string
  description = "The IAM role to associate with the instance profile. To create a new role, this value should be null."
  default     = null
}

variable "friendly_name_prefix" {
  type        = string
  description = "(Required) Friendly name prefix used for tagging and naming AWS resources."
}

variable "iam_role_policy_arns" {
  default     = []
  description = "A set of Amazon Resource Names of IAM role policies to be attached to the PostgreSQL IAM role."
  type        = set(string)
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key arn for AWS KMS Customer managed key. Set to null if not using KMS."
  default     = null
}

variable "db_instance_identifier" {
  type        = string
  description = "The RDS instance identifier for IAM authentication. Used in the RDS IAM policy."
}

variable "db_username" {
  type        = string
  description = "The database username for IAM authentication. Used in the RDS IAM policy."
}