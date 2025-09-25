# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "domain_name" {
  description = "The name of the Route 53 Hosted Zone in which a record will be created."
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

variable "db_parameters" {
  type        = string
  description = "PostgreSQL server parameters for the connection URI. Used to configure the PostgreSQL connection (e.g. sslmode=require)."
  default     = ""
}

variable "network_id" {
  description = "The identity of the VPC in which the security group attached to the PostgreSQL instance will be deployed."
  type        = string
}

variable "network_public_subnets" {
  default     = []
  description = "A list of the identities of the public subnetworks in which resources will be deployed."
  type        = list(string)
}

variable "friendly_name_prefix" {
  type        = string
  description = "(Required) Friendly name prefix used for tagging and naming AWS resources."
}

variable "aws_iam_instance_profile" {
  description = "The AWS IAM instance profile name to be attached to the instance."
  type        = string
}
