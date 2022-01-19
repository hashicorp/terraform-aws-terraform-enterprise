variable "aws_role_arn" {
  type        = string
  description = "The AWS Role ARN to assume for this module."
}

variable "acm_certificate_arn" {
  type        = string
  description = "The ARN of an existing ACM certificate."
}

variable "tfe_license" {
  default = null
  type = object({
    name = string
    path = string
  })
  description = "A map that consists of the newly created secret name and the local path to the Terraform Enterprise license."
}

