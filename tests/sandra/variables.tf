variable "tfe_license" {
  default = null
  type = object({
    name = string
    path = string
  })
  description = "A map that consists of the newly created secret name and the local path to the Terraform Enterprise license."
}
