# Secret Manager and Certificate
# ------------------------------
variable "mitmproxy_ca_certificate_secret" {
  default     = null
  description = <<-EOD
  The identifier of a secret comprising a Base64 encoded PEM certificate file for the mitmproxy Certificate Authority.
  EOD
  type        = string
}

variable "mitmproxy_ca_private_key_secret" {
  default     = null
  description = <<-EOD
  The identifier of a secret comprising a Base64 encoded PEM private key file for the mitmproxy Certificate Authority.
  EOD
  type        = string
}

# Network
# -------
variable "subnet_id" {
  default     = null
  description = "The identity of the VPC in which resources will be deployed."
  type        = string
}

variable "vpc_id" {
  default     = null
  description = "The identity of the VPC in which resources will be deployed."
  type        = string
}

# Proxy Settings
# --------------
variable "name" {
  type        = string
  description = "Name of the proxy server."
  default     = null
}

variable "http_proxy_port" {
  type        = string
  description = "Port used by the proxy server."
  default     = "3128"
}

variable "key_name" {
  default     = null
  description = "The name of the key pair to be used for SSH access to the EC2 instance(s)."
  type        = string
}

variable "proxy_init_module_source" {
  type        = string
  default     = "git::https://github.com/hashicorp/terraform-random-tfe-utility//fixtures/test_proxy_init?ref=main"
  description = "The value of the source argument for the proxy_init module block."
}