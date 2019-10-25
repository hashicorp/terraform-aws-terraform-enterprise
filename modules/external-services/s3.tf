resource "aws_s3_bucket" "tfe_objects" {
  bucket = "${var.prefix}tfe-${var.install_id}"
}
