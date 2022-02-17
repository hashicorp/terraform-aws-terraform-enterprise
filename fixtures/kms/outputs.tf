output "key" {
  value = aws_kms_key.main.id

  description = "The KMS key used to encrypt data."
}

