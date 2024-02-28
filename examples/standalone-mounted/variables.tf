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

variable "tags" {
  type        = map(string)
  description = <<DESC
  (Optional) Map of tags only used for the autoscaling group. If you are using the AWS provider's default_tags,
  please note that it tags every taggable resource except for the autoscaling group, therefore this variable may
  be used to duplicate the key/value pairs in the default_tags if you wish.
  DESC
  default     = {}
}

variable "tfe_subdomain" {
  type        = string
  description = "Subdomain for TFE"
}

variable "distribution" {
  type        = string
  default     = "ubuntu"
  description = "The OS distribution to use, either ubuntu or rhel."
}
