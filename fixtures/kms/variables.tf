variable "key_alias" {
  description = "The key alias for AWS KMS Customer managed key."
  type        = string
}

variable "kms_key_deletion_window" {
  type        = number
  description = "(Optional) Duration in days to destroy the key after it is deleted. Must be between 7 and 30 days."
  default     = 7
}