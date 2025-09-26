# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  iam_instance_role    = try(data.aws_iam_role.existing_instance_role[0], aws_iam_role.instance_role[0])
  iam_instance_profile = try(data.aws_iam_instance_profile.existing_instance_profile[0], aws_iam_instance_profile.postgres_passwordless[0])
}