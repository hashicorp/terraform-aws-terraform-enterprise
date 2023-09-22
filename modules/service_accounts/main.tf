# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "aws_iam_instance_profile" "tfe" {
  count = var.existing_iam_instance_profile_name == null ? 1 : 0

  name_prefix = "${var.friendly_name_prefix}-tfe"
  role        = local.iam_instance_role.name
}

resource "aws_iam_role" "instance_role" {
  count = var.existing_iam_instance_role_name == null ? 1 : 0

  name_prefix        = "${var.friendly_name_prefix}-tfe"
  assume_role_policy = data.aws_iam_policy_document.instance_role[0].json
}

data "aws_iam_policy_document" "instance_role" {
  count = var.existing_iam_instance_profile_name == null ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "secretsmanager" {
  count = var.existing_iam_instance_profile_name == null && !var.enable_airgap && local.secret_arns != [] ? 1 : 0

  policy = data.aws_iam_policy_document.secretsmanager[0].json
  role   = local.iam_instance_role.id

  name = "${var.friendly_name_prefix}-tfe-secretsmanager"
}

data "aws_iam_policy_document" "secretsmanager" {
  count = var.existing_iam_instance_profile_name == null ? 1 : 0

  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    effect    = "Allow"
    resources = local.secret_arns
    sid       = "AllowSecretsManagerSecretAccess"
  }
}

resource "aws_iam_role_policy" "tfe_asg_discovery" {
  count = var.existing_iam_instance_profile_name == null ? 1 : 0

  name   = "${var.friendly_name_prefix}-tfe-asg-discovery"
  role   = local.iam_instance_role.id
  policy = data.aws_iam_policy_document.tfe_asg_discovery[0].json
}

data "aws_iam_policy_document" "tfe_asg_discovery" {
  count = var.existing_iam_instance_profile_name == null ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "autoscaling:Describe*"
    ]

    resources = ["*"]
  }
}

# This will allow you to add any additional policies you may need, regardless
# of whether you're using an existing role and instance profile.
resource "aws_iam_role_policy_attachment" "misc" {
  for_each = var.iam_role_policy_arns

  role       = local.iam_instance_role.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "kms_policy" {
  count = var.existing_iam_instance_profile_name == null ? 1 : 0

  role       = local.iam_instance_role.name
  policy_arn = aws_iam_policy.kms_policy[0].arn
}

resource "aws_iam_policy" "kms_policy" {
  count = var.existing_iam_instance_profile_name == null ? 1 : 0

  name = "${var.friendly_name_prefix}-key"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyPair",
          "kms:GenerateDataKeyPairWithoutPlaintext",
          "kms:GenerateDataKeyPairWithoutPlaintext",
          "kms:ReEncryptFrom",
          "kms:ReEncryptTo",
        ]
        Effect   = "Allow"
        Resource = var.kms_key_arn
      },
    ]
  })
}
