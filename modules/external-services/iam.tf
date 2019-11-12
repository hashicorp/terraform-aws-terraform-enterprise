resource "aws_iam_user" "tfe_objects" {
  name          = "${var.prefix}tfe-object-store-${var.install_id}"
  force_destroy = true
}

## credentials to be passed to archivist
resource "aws_iam_access_key" "tfe_objects" {
  user = aws_iam_user.tfe_objects.name
}

data aws_iam_policy_document "tfe_objects" {
  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.tfe_objects.arn,
      "${aws_s3_bucket.tfe_objects.arn}/*",
    ]
  }
}

resource "aws_iam_user_policy" "tfe_objects" {
  user = aws_iam_user.tfe_objects.name
  name = "${var.prefix}archivist-bucket-${var.install_id}"

  policy = data.aws_iam_policy_document.tfe_objects.json
}
