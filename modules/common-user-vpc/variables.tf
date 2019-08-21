### =================================================================== REQUIRED

variable "vpc_id" {
  type        = "string"
  description = "AWS VPC id to install into"
}

### =================================================================== OPTIONAL

variable "cidr" {
  type        = "string"
  description = "cidr block for vpc"
  default     = "10.0.0.0/16"
}

variable "subnet_tags" {
  type        = "map"
  description = "tags to use to match subnets to use"
  default     = {}
}

variable "allow_list" {
  type        = "list"
  description = "list of CIDRs we allow to access the infrastructure"
  default     = []
}

### ======================================================================= MISC

resource "random_string" "install_id" {
  length  = 8
  special = false
  upper   = false
}
