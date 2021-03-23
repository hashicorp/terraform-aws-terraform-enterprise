output "s3_bucket_bootstrap" {
  value = aws_s3_bucket.tfe_bootstrap_bucket.id
}

output "s3_bucket_bootstrap_arn" {
  value = aws_s3_bucket.tfe_bootstrap_bucket.arn
}

output "s3_bucket_data" {
  value = aws_s3_bucket.tfe_data_bucket.id
}

output "s3_bucket_data_arn" {
  value = aws_s3_bucket.tfe_data_bucket.arn
}