variable "aws_role_arn" {
  type        = string
  description = "The AWS Role ARN to assume for this module."
}

variable "acm_certificate_arn" {
  type        = string
  description = "The ARN of an existing ACM certificate."
}

variable "license_file" {
  type        = string
  description = "The local path to the Terraform Enterprise license to be provided by CI."
}

# KMS
# ---
variable "key_deletion_window" {
  description = "Duration in days to destroy the key after it is deleted. Must be between 7 and 30 days."
  type        = number
  default     = 7
}
