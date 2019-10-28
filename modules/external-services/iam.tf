resource "aws_iam_user" "tfe_objects" {
  name          = "${var.prefix}tfe-object-store-${var.install_id}"
  force_destroy = true
}

## credentials to be passed to archivist
resource "aws_iam_access_key" "tfe_objects" {
  user = "${aws_iam_user.tfe_objects.name}"
}

resource "aws_iam_user_policy" "tfe_objects" {
  user = "${aws_iam_user.tfe_objects.name}"
  name = "${var.prefix}archivist-bucket-${var.install_id}"

  policy = <<__policy
{
    "Version": "2012-10-17",
    "Statement": [{
        "Resource": [
            "arn:aws:s3:::${aws_s3_bucket.tfe_objects.id}",
            "arn:aws:s3:::${aws_s3_bucket.tfe_objects.id}/*"
        ],
        "Effect": "Allow",
        "Action": [
            "s3:*"
        ]
    }]
}
__policy
}
