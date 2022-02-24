resource "aws_kms_key" "main" {
  deletion_window_in_days = var.key_deletion_window
  description             = "AWS KMS Customer-managed key to encrypt TFE and other resources"
  enable_key_rotation     = false
  is_enabled              = true
  key_usage               = "ENCRYPT_DECRYPT"
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.key_alias}"
  target_key_id = aws_kms_key.main.key_id
}

data "aws_iam_user" "ci_s3" {
  user_name = "TFE-S3"
}

resource "aws_kms_grant" "main" {
  grantee_principal = data.aws_iam_user.ci_s3.arn
  key_id            = aws_kms_key.main.key_id
  operations = [
    "Decrypt",
    "DescribeKey",
    "Encrypt",
    "GenerateDataKey",
    "GenerateDataKeyPair",
    "GenerateDataKeyPairWithoutPlaintext",
    "GenerateDataKeyPairWithoutPlaintext",
    "ReEncryptFrom",
    "ReEncryptTo",
  ]
}