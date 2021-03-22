variable "friendly_name_prefix" {
  type        = string
  description = "(Required) Friendly name prefix used for tagging and naming AWS resources."
}

variable "aws_bucket_bootstrap_arn" {}

variable "aws_bucket_data_arn" {}

variable "kms_key_arn" {}

variable "common_tags" {
  type        = map(string)
  description = "(Optional) Map of common tags for all taggable AWS resources."
  default     = {}
}
