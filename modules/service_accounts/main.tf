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
  count  = var.enable_airgap ? 0 : 1
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

resource "aws_iam_role_policy_attachment" "kms_policy" {
  role       = aws_iam_role.instance_role.name
  policy_arn = aws_iam_policy.kms_policy.arn
}

resource "aws_iam_policy" "kms_policy" {
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
        Resource = "${var.kms_key_arn}"
      },
    ]
  })
}
