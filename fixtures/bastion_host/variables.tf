# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Network
# -------

variable "subnet_id" {
  default     = null
  description = "The identity of the VPC in which resources will be deployed."
  type        = string
}

variable "vpc_id" {
  default     = null
  description = "The identity of the VPC in which resources will be deployed."
  type        = string
}

# BASTION SETTINGS
# ----------------

variable "name" {
  type        = string
  description = "Name of the bastion host."
  default     = null
}

variable "key_name" {
  default     = null
  description = "The name of the key pair to be used for SSH access to the EC2 instance(s)."
  type        = string
}