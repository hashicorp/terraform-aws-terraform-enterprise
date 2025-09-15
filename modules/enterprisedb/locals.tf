# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  user_data_template = "${path.module}/templates/aws.ubuntu.docker.edb.sh.tpl"
  compose            = file("${path.module}/templates/compose.yaml")
  tfe_user_data = templatefile(
    local.user_data_template,
    {
      registry_username   = var.registry_username
      registry_password   = var.registry_password
      docker_compose_yaml = base64encode(local.compose)
    }
  )
  tags = concat(
    [
      {
        key                 = "Name"
        value               = "${var.friendly_name_prefix}-enterprisedb"
        propagate_at_launch = true
      },
    ],
    [
      for k, v in var.asg_tags : {
        key                 = k
        value               = v
        propagate_at_launch = true
      }
    ]
  )
  tag_map                           = { for tag in local.tags : tag.key => tag.value }
}