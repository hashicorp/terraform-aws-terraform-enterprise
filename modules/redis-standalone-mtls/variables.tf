# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# VM Configuration
# ----------------

variable "aws_iam_instance_profile" {
  description = "The name of the IAM instance profile to be associated with the TFE EC2 instance(s)."
  type        = string
}

variable "friendly_name_prefix" {
  type        = string
  description = "(Required) Friendly name prefix used for tagging and naming AWS resources."
}

variable "health_check_grace_period" {
  default     = null
  description = "The health grace period aws provides to allow for an instance to pass it's health check."
  type        = number
}

variable "health_check_type" {
  description = "Type of health check to perform on the instance."
  type        = string
  default     = "ELB"

  validation {
    condition     = contains(["ELB", "EC2"], var.health_check_type)
    error_message = "Must be one of [ELB, EC2]."
  }
}

variable "instance_type" {
  default     = "m5.xlarge"
  description = "The instance type of EC2 instance(s) to create."
  type        = string
}

variable "network_id" {
  description = "The identity of the VPC in which the security group attached to the TFE EC2 instance will be delpoyed."
  type        = string
}

variable "network_subnets_private" {
  description = "A list of the identities of the private subnetworks in which the EC2 autoscaling group will be deployed."
  type        = list(string)
}

variable "asg_tags" {
  type        = map(string)
  description = "(Optional) Map of tags only used for the autoscaling group. If you are using the AWS provider's default_tags, please note that it tags every taggable resource except for the autoscaling group, therefore this variable may be used to duplicate the key/value pairs in the default_tags if you wish."
  default     = {}
}

variable "network_private_subnet_cidrs" {
  type        = list(string)
  description = "(Optional) List of private subnet CIDR ranges to create in VPC."
  default     = ["10.0.32.0/20", "10.0.48.0/20"]
}

variable "key_name" {
  default     = null
  description = "The name of the key pair to be used for SSH access to the EC2 instance(s)."
  type        = string
}

variable "ec2_launch_template_tag_specifications" {
  description = "(Optional) List of tag specifications to apply to the launch template."
  type = list(object({
    resource_type = string
    tags          = map(string)
  }))
  default = []
}


# Domain Installation
# -------------------

variable "domain_name" {
  description = "The name of the Route 53 Hosted Zone in which a record will be created."
  type        = string
}

# Redis  Variables
# ----------------

variable "redis_port" {
  description = "The base port for redis isntances"
  type        = number
  default     = 6379
}

variable "redis_authentication_mode" {
  description = "The authentincation mode for redis server instances.  Must be one of [USER_AND_PASSWORD, PASSWORD, NONE]."
  type        = string
  default     = "NONE"
  validation {
    condition     = contains(["USER_AND_PASSWORD", "PASSWORD", "NONE"], var.redis_authentication_mode)
    error_message = "Must be one of [USER_AND_PASSWORD, PASSWORD, NONE]."
  }
}

variable "redis_use_password_auth" {
  description = "A boolean which indicates if password authentication is required by the Redis"
  type        = bool
  default     = false
}

variable "redis_client_key_secret_id" {
  type        = string
  description = "The secrets manager secret ID of the Base64 & PEM encoded private key for redis."
}

variable "redis_client_certificate_secret_id" {
  type        = string
  description = "The secrets manager secret ID of the Base64 & PEM encoded certificate for redis."
}

variable "redis_ca_certificate_secret_id" {
  type        = string
  description = "The secrets manager secret ID of the Base64 & PEM encoded certificate for redis."
}
  