variable "aws_access_key_id" {
  type        = string
  description = "The identity of the access key which TFE will use to authenticate with S3."
}

variable "aws_secret_access_key" {
  type        = string
  description = "The secret access key which TFE will use to authenticate with S3."
}

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

variable "object_storage_iam_user_name" {
  type        = string
  description = "The name of the IAM user which will be authorized to access the S3 storage bucket."
}
