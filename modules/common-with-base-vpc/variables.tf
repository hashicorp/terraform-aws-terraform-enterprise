### =================================================================== REQUIRED

### =================================================================== OPTIONAL

variable "cidr" {
  type        = "string"
  description = "cidr block for vpc"
  default     = "10.0.0.0/16"
}

### ======================================================================= MISC

resource "random_string" "install_id" {
  length  = 8
  special = false
  upper   = false
}
