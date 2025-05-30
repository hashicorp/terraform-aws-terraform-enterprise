# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  friendly_name_prefix         = random_string.friendly_name.id
  network_private_subnet_cidrs = ["10.0.32.0/20", "10.0.48.0/20", "10.0.112.0/20"]
}
