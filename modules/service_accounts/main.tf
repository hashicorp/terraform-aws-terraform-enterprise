resource "aws_iam_instance_profile" "tfe" {
  name_prefix = "${var.friendly_name_prefix}-tfe"
  role        = aws_iam_role.instance_role.name
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = "${var.friendly_name_prefix}-tfe"
  assume_role_policy = data.aws_iam_policy_document.instance_role.json
}

data "aws_iam_policy_document" "instance_role" {
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
  policy = data.aws_iam_policy_document.secretsmanager.json
  role   = aws_iam_role.instance_role.id

  name = "${var.friendly_name_prefix}-tfe-secretsmanager"
}

data "aws_iam_policy_document" "secretsmanager" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    effect    = "Allow"
    resources = local.secret_arns
    sid       = "AllowSecretsManagerSecretAccess"
  }
}

resource "aws_iam_role_policy" "s3_data_bucket_put" {
  name   = "${var.friendly_name_prefix}-tfe-data"
  role   = aws_iam_role.instance_role.id
  policy = data.aws_iam_policy_document.tfe_s3_data_bucket_put.json
}

data "aws_iam_policy_document" "tfe_s3_data_bucket_put" {
  statement {
    sid    = "AllowS3ActionsData"
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      var.aws_bucket_data_arn,
      "${var.aws_bucket_data_arn}/*"
    ]
  }

  statement {
    sid    = "AllowKMSActionsData"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:ReEncrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey",
    ]
    resources = [
      var.kms_key_arn,
    ]
  }
}

resource "aws_iam_role_policy" "tfe_asg_discovery" {
  name   = "${var.friendly_name_prefix}-tfe-asg-discovery"
  role   = aws_iam_role.instance_role.id
  policy = data.aws_iam_policy_document.tfe_asg_discovery.json
}

data "aws_iam_policy_document" "tfe_asg_discovery" {
  statement {
    effect = "Allow"

    actions = [
      "autoscaling:Describe*"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "misc" {
  for_each = var.iam_role_policy_arns

  role       = aws_iam_role.instance_role.name
  policy_arn = each.value
}
