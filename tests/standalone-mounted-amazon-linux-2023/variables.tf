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

variable "tfe_subdomain" {
  type        = string
  description = "Subdomain for TFE"
}

variable "distribution" {
  type        = string
  description = "The distribution to use for the instance."
  default     = "ubuntu"
}

variable "key_name" {
  default     = null
  description = "The name of the key pair to be used for SSH access to the EC2 instance(s)."
  type        = string
}
