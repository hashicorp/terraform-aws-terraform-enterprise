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

resource "aws_kms_grant" "main" {
  count             = var.iam_principal != null ? 1 : 0
  grantee_principal = var.iam_principal
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