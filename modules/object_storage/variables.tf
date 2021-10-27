variable "kms_key_arn" {
  description = "The Amazon Resource Name of the KMS key with which S3 storage bucket objects will be encrypted."
  type        = string
}

variable "friendly_name_prefix" {
  type        = string
  description = "(Required) Friendly name prefix used for tagging and naming AWS resources."
}

variable "logging_bucket" {
  type        = string
  description = "S3 bucket name for logging of resources to. Requires a bucket in the same region that TFE is in."
  default     = null
}

variable "logging_prefix" {
  type        = string
  description = "Optional prefix to prepend to TFE resource logs in S3 bucket"
  default     = null
}
