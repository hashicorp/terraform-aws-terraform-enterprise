variable "aws_role_arn" {
  type        = string
  description = "The AWS Role ARN to assume for this module."
}

variable "domain_name" {
  type        = string
  description = "Domain for creating the Terraform Enterprise subdomain on."
}

variable "external_bootstrap_bucket" {
  type        = string
  description = "The name of the S3 bucket for bootstrap artifacts."
  default     = null
}

variable "acm_certificate_arn" {
  type        = string
  description = "The ARN of an existing ACM certificate."
}

variable "network_id" {
  description = "The identity of the VPC in which resources will be deployed."
  type        = string
}

variable "network_public_subnets" {
  description = "A list of the identities of the public subnetworks in which resources will be deployed."
  type        = list(string)
}

variable "network_private_subnets" {
  description = "A list of the identities of the private subnetworks in which resources will be deployed."
  type        = list(string)
}

variable "network_private_subnet_cidrs" {
  type        = list(string)
  description = "List of private subnet CIDR ranges."
}

variable "key_name" {
  description = "The name of the key pair to be used for SSH access to the EC2 instance(s)."
  type        = string
}

variable "proxy_certificate_bucket_object_key" {
  description = "The key of the proxy certificate bucket object."
  type        = string
}

variable "proxy_private_key_bucket_object_key" {
  description = "The key of the proxy private key bucket object."
  type        = string
}
