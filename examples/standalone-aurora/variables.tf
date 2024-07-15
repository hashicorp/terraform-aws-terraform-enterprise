# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "acm_certificate_arn" {
  type        = string
  description = "The ARN of an existing ACM certificate."
}

variable "domain_name" {
  type        = string
  description = "Domain for creating the Terraform Enterprise subdomain on."
}

variable "license_file" {
  type        = string
  description = "The local path to the Terraform Enterprise license."
}

variable "private_key_pem_secret_id" {
  type        = string
  description = "The secrets manager secret ID of the Base64 & PEM encoded TLS private key for tfe."
}

variable "certificate_pem_secret_id" {
  type        = string
  description = "The secrets manager secret ID of the Base64 & PEM encoded TLS certificate for tfe."
}

variable "aurora_db_password" {
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

variable "aurora_cluster_instance_enable_single" {
  type        = bool
  description = "Creates only a single AWS RDS Aurora Cluster Instance."
}

variable "aurora_cluster_instance_replica_count" {
  type        = number
  description = "Number of extra cluster instances to create. Should be 0 if `aurora_cluster_instance_enable_single` is set to `true`."
}
