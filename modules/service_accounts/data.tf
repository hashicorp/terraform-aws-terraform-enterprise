# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data "aws_iam_instance_profile" "tfe" {
  count = var.existing_iam_instance_profile_name == null ? 0 : 1
  name  = var.existing_iam_instance_profile_name
}

data "aws_iam_role" "instance_role" {
  count = var.existing_iam_instance_role_name == null ? 0 : 1
  name  = var.existing_iam_instance_role_name
}