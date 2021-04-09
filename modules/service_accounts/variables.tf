variable "friendly_name_prefix" {
  type        = string
  description = "(Required) Friendly name prefix used for tagging and naming AWS resources."
}

variable "aws_bucket_bootstrap_arn" {
  description = "The Amazon Resource Name of the S3 storage bucket which contains TFE bootstarp artifacts."
  type        = string
}

variable "aws_bucket_data_arn" {
  description = "The Amazon Resource Name of the S3 storage bucket whih contains TFE runtime data."
  type        = string
}

variable "kms_key_arn" {
  description = "The Amazon Resource Name of the KMS key which is used to encrypt S3 storage bucket objects."
  type        = string
}

variable "common_tags" {
  type        = map(string)
  description = "(Optional) Map of common tags for all taggable AWS resources."
  default     = {}
}
