### =================================================================== REQUIRED

variable "vpc_id" {
  type        = string
  description = "AWS VPC id to install into"
}

variable "prefix" {
  type        = string
  description = "Prefix for resource names"
}

### =================================================================== OPTIONAL

variable "subnet_tags" {
  type        = map(string)
  description = "tags to use to match subnets to use"
  default     = {}
}

variable "allow_list" {
  type        = list(string)
  description = "list of CIDRs we allow to access the infrastructure"
  default     = []
}

### ======================================================================= MISC

resource "random_string" "install_id" {
  length  = 8
  special = false
  upper   = false
}
