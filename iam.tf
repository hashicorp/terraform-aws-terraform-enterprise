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

