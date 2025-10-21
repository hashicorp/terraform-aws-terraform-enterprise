# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "ca_certificate_secret_id" {
  type        = string
  description = <<-EOD
  A Secrets Manager secret which contains the Base64 encoded version of a PEM encoded public certificate of a
  certificate authority (CA) to be trusted by the EC2 instance.
  EOD
}

variable "existing_iam_instance_profile_name" {
  description = "The IAM instance profile to be attached to the TFE EC2 instance(s). Leave the value null to create a new one."
  type        = string
}

variable "existing_iam_instance_role_name" {
  type        = string
  description = "The IAM role to associate with the instance profile. To create a new role, this value should be null."
}

variable "friendly_name_prefix" {
  type        = string
  description = "(Required) Friendly name prefix used for tagging and naming AWS resources."
}

variable "iam_role_policy_arns" {
  default     = []
  description = "A set of Amazon Resource Names of IAM role policies to be attached to the TFE IAM role."
  type        = set(string)
}

variable "enable_airgap" {
  type        = bool
  description = "If this is an airgapped installation, then the virtual machine will not need to have a role policy that allows it to access the secrets manager."
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key arn for AWS KMS Customer managed key."
}

variable "tfe_license_secret_id" {
  type        = string
  description = "The Secrets Manager secret under which the Base64 encoded Terraform Enterprise license is stored."
}

variable "vm_certificate_secret_id" {
  default     = null
  type        = string
  description = <<-EOD
  A Secrets Manager secret ARN which contains the Base64 encoded version of a PEM encoded public certificate for the Virtual
  Machine Scale Set.
  EOD
}

variable "vm_key_secret_id" {
  default     = null
  type        = string
  description = <<-EOD
  A Secrets Manager secret ARN which contains the Base64 encoded version of a PEM encoded private key for the Virtual Machine
  Scale Set.
  EOD
}

variable "redis_client_key_secret_id" {
  type        = string
  default     = null
  description = "The secrets manager secret ID of the Base64 & PEM encoded private key for redis."
}

variable "redis_client_certificate_secret_id" {
  type        = string
  default     = null
  description = "The secrets manager secret ID of the Base64 & PEM encoded certificate for redis."
}

variable "redis_ca_certificate_secret_id" {
  type        = string
  default     = null
  description = "The secrets manager secret ID of the Base64 & PEM encoded certificate for redis."
}

variable "postgres_ca_certificate_secret_id" {
  type        = string
  default     = null
  description = "The secrets manager secret ID of the Base64 & PEM encoded certificate for postgres."
}

variable "postgres_client_certificate_secret_id" {
  type        = string
  default     = null
  description = "The secrets manager secret ID of the Base64 & PEM encoded certificate for postgres."
}

variable "postgres_client_key_secret_id" {
  type        = string
  default     = null
  description = "The secrets manager secret ID of the Base64 & PEM encoded private key for postgres."
}

variable "redis_enable_iam_auth" {
  type        = bool
  description = "Whether to enable IAM authentication for Redis. Used for passwordless authentication."
  default     = false
}
