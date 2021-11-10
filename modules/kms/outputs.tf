output "key" {
  value = aws_kms_key.main

  description = "The KMS key used to encrypt data."
}