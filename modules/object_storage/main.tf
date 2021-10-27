resource "aws_s3_bucket" "tfe_data_bucket" {
  #checkov:skip=CKV_AWS_144:While cross-region might make sense someday, right now it doesn't for TFE
  bucket = "${var.friendly_name_prefix}-tfe-data"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.kms_key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  dynamic "logging" {
    for_each = var.logging_bucket == null ? [] : [var.logging_bucket]
    content {
      target_bucket = logging.value
      target_prefix = var.logging_prefix
    }
  }

  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "tfe_data" {
  bucket = aws_s3_bucket.tfe_data_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
