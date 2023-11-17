# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {

  common_tags = {
    Environment = local.utility_module_test ? "tfe_modules_test" : "tfe_team_dev"
    Description = "Active/Active on RHEL with Proxy scenario deployed from CircleCI"
    Repository  = "hashicorp/terraform-aws-terraform-enterprise"
    Team        = "Terraform Enterprise on Prem"
    OkToDelete  = "True"
  }

  http_proxy_port       = "3128"
  friendly_name_prefix  = random_string.friendly_name.id
  iam_principal         = data.aws_iam_user.ci_s3.arn
  load_balancing_scheme = "PUBLIC"
  registry              = "quay.io"
  ssh_user              = "ec2-user"
  ssm_policy_arn        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  test_name             = "${local.friendly_name_prefix}-test-active-active-rhel-proxy"
  utility_module_test   = (var.license_file == null && var.is_replicated_deployment)
}
