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
  type        = map
  description = "tags to use to match subnets to use"
  default     = {}
}

variable "ingress_allow_list" {
  type        = list
  description = "list of CIDR blocks we allow to access the infrastructure"
  default     = []
}

variable "egress_allow_list" {
  type        = list
  description = "List of CIDR blocks we allow the infrastructure to access"
  default     = ["0.0.0.0/0"]
}


### ======================================================================= MISC

resource "random_string" "install_id" {
  length  = 8
  special = false
  upper   = false
}
