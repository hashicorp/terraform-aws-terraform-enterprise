variable "default_ami_id" {}

variable "userdata_script" {}

variable "aws_lb" {}

variable "aws_lb_target_group_tfe_tg_443_arn" {}

variable "aws_lb_target_group_tfe_tg_8800_arn" {}

variable "aws_iam_instance_profile" {}

variable "bastion_sg" {}

variable "bastion_key" {}

variable "network_id" {}

variable "network_subnets_private" {}

variable "instance_type" {}

variable "active_active" {
  type        = bool
  description = "Flag for active-active configuation: true for active-active, false for standalone"
}

variable "ami_id" {
  type        = string
  description = "AMI ID to use for TFE instances and bastion host"
}

variable "friendly_name_prefix" {
  type        = string
  description = "(Required) Friendly name prefix used for tagging and naming AWS resources."
}

variable "node_count" {
  type        = number
  description = "The number of nodes you want in your autoscaling group (1 for standalone, 2 for active-active configuration)"
}

variable "tfe_license_name" {
  type    = string
  default = "ptfe-license.rli"
}

variable "common_tags" {
  type        = map(string)
  description = "(Optional) Map of common tags for all taggable AWS resources."
  default     = {}
}

variable "network_private_subnet_cidrs" {
  type        = list(string)
  description = "(Optional) List of private subnet CIDR ranges to create in VPC."
  default     = ["10.0.32.0/20", "10.0.48.0/20"]
}
