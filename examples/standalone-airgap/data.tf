# Find existing virtual machine image
# -----------------------------------
data "aws_ami" "existing" {
  count       = local.ami_search ? 1 : 0
  owners      = var.ami_owners
  most_recent = var.ami_most_recent

  filter {
    name   = var.ami_filter_name
    values = [var.ami_filter_value]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}