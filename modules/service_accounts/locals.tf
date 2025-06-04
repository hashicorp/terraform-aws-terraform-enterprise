# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  secret_arns = [for secret in [
    var.ca_certificate_secret_id,
    var.tfe_license_secret_id,
    var.vm_certificate_secret_id,
    var.vm_key_secret_id,
    var.redis_ca_certificate_secret_id,
    var.redis_client_certificate_secret_id,
    var.redis_client_key_secret_id
  ] : secret if secret != null]

  iam_instance_role    = try(data.aws_iam_role.existing_instance_role[0], aws_iam_role.instance_role[0])
  iam_instance_profile = try(data.aws_iam_instance_profile.existing_instance_profile[0], aws_iam_instance_profile.tfe[0])
}
