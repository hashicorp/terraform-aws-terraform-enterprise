# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "aws_s3_bucket" "tfe_data_bucket" {
  bucket        = "${var.friendly_name_prefix}-tfe-data"
  force_destroy = true
}
resource "aws_s3_bucket_ownership_controls" "tfe_data_bucket_ownership_controls" {
  bucket = aws_s3_bucket.tfe_data_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "tfe_data_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.tfe_data_bucket_ownership_controls]

  bucket = aws_s3_bucket.tfe_data_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfe_data_bucket_encryption" {
  bucket = aws_s3_bucket.tfe_data_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "tfe_data_bucket_versioning" {
  bucket = aws_s3_bucket.tfe_data_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "tfe_data" {
  bucket = aws_s3_bucket.tfe_data_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

data "aws_iam_policy_document" "tfe_data" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]
    effect = "Allow"
    principals {
      identifiers = [var.iam_principal.arn]
      type        = "AWS"
    }
    resources = [aws_s3_bucket.tfe_data_bucket.arn]
    sid       = "AllowS3ListBucketData"
  }

  statement {
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
    ]
    effect = "Allow"
    principals {
      identifiers = [var.iam_principal.arn]
      type        = "AWS"
    }
    resources = ["${aws_s3_bucket.tfe_data_bucket.arn}/*"]
    sid       = "AllowS3ManagementData"
  }
}

resource "aws_s3_bucket_policy" "tfe_data" {
  # Depending on aws_s3_bucket_public_access_block.tfe_data avoids an error due to conflicting, simultaneous operations
  # against the bucket.
  bucket = aws_s3_bucket_public_access_block.tfe_data.bucket
  policy = data.aws_iam_policy_document.tfe_data.json
}
