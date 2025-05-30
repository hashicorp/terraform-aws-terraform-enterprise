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


variable "redis_ca_cert_path" {
  type        = string
  description = "The secrets manager secret ID of the Base64 & PEM encoded TLS certificate for tfe."
}

variable "redis_client_cert_path" {
  type        = string
  description = "The secrets manager secret ID of the Base64 & PEM encoded TLS certificate for tfe."
}

variable "redis_client_key_path" {
  type        = string
  description = "The secrets manager secret ID of the Base64 & PEM encoded TLS certificate for tfe."
}
variable "redis_client_ca" {
  type        = string
  description = "The secrets manager secret ID of the Base64 & PEM encoded TLS certificate for tfe."
}
variable "redis_client_cert" {
  type        = string
  description = "The secrets manager secret ID of the Base64 & PEM encoded TLS certificate for tfe."
}
variable "redis_client_key" {
  type        = string
  description = "The secrets manager secret ID of the Base64 & PEM encoded TLS certificate for tfe."
}

variable private_key_pem_secret_id {
  type        = string
  description = "The secrets manager secret ID of the Base64 & PEM encoded private key for tfe."
}
variable "certificate_pem_secret_id" {
  type        = string
  description = "The secrets manager secret ID of the Base64 & PEM encoded certificate for tfe."
}

variable redis_private_key_pem_secret_id {
  type        = string
  description = "The secrets manager secret ID of the Base64 & PEM encoded private key for tfe."
}

variable "redis_certificate_pem_secret_id" {
  type        = string
  description = "The secrets manager secret ID of the Base64 & PEM encoded certificate for tfe."
}

variable "redis_ca_certificate_pem_secret_id" {
  type        = string
  description = "The secrets manager secret ID of the Base64 & PEM encoded certificate for tfe."
}

