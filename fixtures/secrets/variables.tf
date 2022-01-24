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
  type        = string
}

variable "ca_private_key" {
  default     = null
  description = "The secret identifier and data of a PEM private key file for a Certificate Authority."
  type = object({
    id   = string
    data = string
  })
}