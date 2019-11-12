resource "random_string" "default_enc_password" {
  length  = 32
  upper   = true
  special = false
}

locals {
  encryption_password = var.encryption_password != "" ? var.encryption_password : random_string.default_enc_password.result
}

