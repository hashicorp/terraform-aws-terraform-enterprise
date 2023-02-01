# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  friendly_name_prefix = random_string.friendly_name.id
  ami_search           = var.ami_id == null ? true : false
  ami_id               = local.ami_search ? data.aws_ami.existing[0].id : var.ami_id
}