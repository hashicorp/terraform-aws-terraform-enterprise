
variable "fqdn" {
  description = "The fully qualified domain name of the load balancer."
  type        = string
}
variable "active_active" {
  default     = true
  description = "A boolean that indicates if the TFE deployment is Active/Active or Standalone."
  type        = bool
}

variable "aws_bucket_data" {
  description = "The name of the S3 storage bucket which contains TFE runtime data."
  type        = string
}
variable "aws_region" {
  description = "The region in which the S3 storage bucket which contains TFE runtime data is deployed."
  type        = string
}

variable "tfe_license_secret" {
  type = object({
    arn = string
  })
  description = "The Secrets Manager secret under which the Base64 encoded Terraform Enterprise license is stored."
}

variable "kms_key_arn" {
  description = "The Amazon Resource Name of the KMS key which is used to encrypt S3 storage bucket objects."
  type        = string
}
variable "redis_host" {
  default     = ""
  description = "The IP address of the primary node in the Redis Elasticache replication group."
  type        = string
}
variable "redis_pass" {
  default     = ""
  description = "The password which is required to create connections with the Redis Elasticache replication group."
  type        = string
}
variable "redis_port" {
  default     = ""
  description = "The port number on which the Redis Elasticache replication group accepts connections."
  type        = string
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

variable "pg_netloc" {
  description = "The connection endpoint of the PostgreSQL RDS instance in address:port format."
  type        = string
}
variable "pg_dbname" {
  description = "The name of the PostgreSQL RDS instance."
  type        = string
}
variable "pg_user" {
  description = "The name of the main PostgreSQL user."
  type        = string
}
variable "pg_password" {
  description = "The password of the main PostgreSQL user."
  type        = string
}

variable "ca_certificate_secret" {
  type = object({
    arn = string
  })
  description = <<-EOD
  A Secrets Manager secret which contains the Base64 encoded version of a PEM encoded public certificate of a
  certificate authority (CA) to be trusted by the EC2 instance.
  EOD
}

variable "proxy_ip" {
  description = "The IP address of the HTTP proxy through which TFE traffic will be routed."
  type        = string
}

variable "no_proxy" {
  type        = list(string)
  description = "(Optional) List of IP addresses to not proxy"
  default     = []
}

variable "iact_subnet_list" {
  default     = []
  description = "A list of CIDR masks that configure the ability to retrieve the IACT from outside the host."
  type        = list(string)
}

variable "iact_subnet_time_limit" {
  default     = 60
  description = "The time limit that requests from the subnets listed can request the IACT, as measured from the instance creation in minutes."
  type        = number
}
