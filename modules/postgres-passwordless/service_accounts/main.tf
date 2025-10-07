# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "aws_iam_instance_profile" "postgres_passwordless" {
  count = var.existing_iam_instance_profile_name == null ? 1 : 0

  name_prefix = "${var.friendly_name_prefix}-postgres-passwordless"
  role        = local.iam_instance_role.name
}

resource "aws_iam_role" "instance_role" {
  count = var.existing_iam_instance_role_name == null ? 1 : 0

  name_prefix        = "${var.friendly_name_prefix}-postgres-passwordless"
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

# RDS IAM authentication policy for passwordless database access
resource "aws_iam_role_policy" "rds_iam_auth" {
  count = var.existing_iam_instance_profile_name == null ? 1 : 0

  policy = data.aws_iam_policy_document.rds_iam_auth[0].json
  role   = local.iam_instance_role.id

  name = "${var.friendly_name_prefix}-postgres-passwordless-rds-auth"
}

data "aws_iam_policy_document" "rds_iam_auth" {
  count = var.existing_iam_instance_profile_name == null ? 1 : 0

  statement {
    actions = [
      "rds-db:connect"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:rds-db:*:*:dbuser:${var.db_instance_identifier}/${var.db_username}"
    ]
    sid = "AllowRDSIAMAuthentication"
  }
}

# Basic EC2 and CloudWatch permissions
resource "aws_iam_role_policy" "basic_permissions" {
  count = var.existing_iam_instance_profile_name == null ? 1 : 0

  policy = data.aws_iam_policy_document.basic_permissions[0].json
  role   = local.iam_instance_role.id

  name = "${var.friendly_name_prefix}-postgres-passwordless-basic"
}

data "aws_iam_policy_document" "basic_permissions" {
  count = var.existing_iam_instance_profile_name == null ? 1 : 0

  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    effect    = "Allow"
    resources = ["*"]
    sid       = "AllowBasicEC2AndCloudWatchAccess"
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
  count = var.existing_iam_instance_profile_name == null && var.kms_key_arn != null ? 1 : 0

  role       = local.iam_instance_role.name
  policy_arn = aws_iam_policy.kms_policy[0].arn
}

resource "aws_iam_policy" "kms_policy" {
  count = var.existing_iam_instance_profile_name == null && var.kms_key_arn != null ? 1 : 0

  name = "${var.friendly_name_prefix}-postgres-passwordless-kms"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:GenerateDataKey",
        ]
        Effect   = "Allow"
        Resource = var.kms_key_arn
      },
    ]
  })
}