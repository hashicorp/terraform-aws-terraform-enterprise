variable "tfe_license" {
  default = null
  type = object({
    name = string
    path = string
  })
  description = "A map that consists of the newly created secret name and the local path to the Terraform Enterprise license."
}

variable "ca_certificate_secret" {
  default     = null
  description = "The secret identifier and data of a PEM certificate file for a Certificate Authority."
  type = object({
    name = string
    data = string
  })
}

variable "ca_private_key_secret" {
  default     = null
  description = "The secret identifier and data of a PEM private key file for a Certificate Authority."
  type = object({
    name = string
    data = string
  })
}

variable "certificate_pem_secret" {
  default     = null
  description = "The secret identifier and data of a PEM certificate file for a TLS."
  type = object({
    name = string
    data = string
  })
}

variable "private_key_pem_secret" {
  default     = null
  description = "The secret identifier and data of a PEM private key file for a TLS."
  type = object({
    name = string
    data = string
  })
}