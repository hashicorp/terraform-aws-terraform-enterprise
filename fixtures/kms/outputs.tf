output "key" {
  value = aws_kms_key.main.arn

  description = "The KMS key used to encrypt data."
}

