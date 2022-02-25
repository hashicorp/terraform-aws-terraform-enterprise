variable "key_alias" {
  description = "The key alias for AWS KMS Customer managed key."
  type        = string
}

variable "key_deletion_window" {
  description = "Duration in days to destroy the key after it is deleted. Must be between 7 and 30 days."
  type        = number
  default     = 7
}

variable "iam_principal" {
  description = "The IAM principal (role or user) that will be authorized to use the key."
  type        = string
  default     = null
}