
variable "fqdn" {}
variable "active_active" {
  default = true
  type    = bool
}
variable "generated_bastion_key_private" {}
variable "aws_bucket_bootstrap" {}
variable "aws_bucket_data" {}
variable "aws_region" {}
variable "tfe_license" {}
variable "kms_key_arn" {}
variable "redis_host" {
  default = ""
}
variable "redis_pass" {
  default = ""
}
variable "redis_port" {
  default = ""
}

variable "redis_use_password_auth" {
  type        = bool
  default     = false
  description = "Determines if the Replicated configuration is aware to use password auth."
}

variable "redis_use_tls" {
  type        = bool
  default     = false
  description = "Determines if the Replicated configuration is aware to use TLS/HTTPS."
}

variable "pg_netloc" {}
variable "pg_dbname" {}
variable "pg_user" {}
variable "pg_password" {}

variable "proxy_ip" {}
variable "proxy_cert_bundle_name" {
  type        = string
  description = "(Optional) name of cert bundle stored in S3"
  default     = ""
}
variable "no_proxy" {
  type        = list(string)
  description = "(Optional) List of IP addresses to not proxy"
  default     = []
}

variable "friendly_name_prefix" {}
