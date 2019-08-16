resource "aws_iam_role" "ptfe" {
  name = "ptfe-${module.common.install_id}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ptfe" {
  name = "ptfe-${module.common.install_id}"
  role = "${aws_iam_role.ptfe.name}"
}
