data "aws_iam_policy_document" "ptfe" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com",
      ]
    }
  }
}
resource "aws_iam_role" "ptfe" {
  name = "ptfe-${module.common.install_id}"

  assume_role_policy = data.aws_iam_policy_document.ptfe.json
}

resource "aws_iam_instance_profile" "ptfe" {
  name = "${var.prefix}-${module.common.install_id}"
  role = aws_iam_role.ptfe.name
}

resource "aws_iam_role_policy_attachment" "ptfe_ssm" {
  count      = var.enable_ssm_access ? 1 : 0
  role       = aws_iam_role.ptfe.name
  policy_arn = "${var.arn_format}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
