variable "aws_access_key_id" {
  type        = string
  description = "The identity of the access key which TFE will use to authenticate with S3."
}

variable "aws_secret_access_key" {
  type        = string
  description = "The secret access key which TFE will use to authenticate with S3."
}

variable "acm_certificate_arn" {
  type        = string
  description = "The ARN of an existing ACM certificate."
}

variable "aws_role_arn" {
  type        = string
  description = "The AWS Role ARN to assume for this module."
}

variable "ca_certificate_secret_name" {
  type        = string
  description = "The secrets manager secret name of the Base64 encoded CA certificate."
}

variable "ca_private_key_secret_name" {
  type        = string
  description = "The secrets manager secret name of the Base64 encoded CA private key."
}

variable "domain_name" {
  type        = string
  description = "Domain for creating the Terraform Enterprise subdomain on."
}

variable "key_name" {
  default     = null
  description = "The name of the key pair to be used for SSH access to the EC2 instance(s)."
  type        = string
}

variable "license_file" {
  default     = null
  type        = string
  description = "The local path to the Terraform Enterprise license to be provided by CI."
}

variable "object_storage_iam_user_name" {
  type        = string
  description = "The name of the IAM user which will be authorized to access the S3 storage bucket."
}

variable "tfe_license_secret_id" {
  default     = null
  type        = string
  description = "The Secrets Manager secret ARN under which the Base64 encoded Terraform Enterprise license is stored."
}
