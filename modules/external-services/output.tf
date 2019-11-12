output "iam_access_key" {
  value = aws_iam_access_key.tfe_objects.id
}

output "iam_secret_key" {
  value = aws_iam_access_key.tfe_objects.secret
}

output "s3_bucket" {
  value = aws_s3_bucket.tfe_objects.id
}

output "s3_region" {
  value = aws_s3_bucket.tfe_objects.region
}

output "database_password" {
  value = random_string.database_password.result
}

output "database_username" {
  value = var.database_username
}

output "database_endpoint" {
  value = aws_rds_cluster.tfe.endpoint
}

output "database_name" {
  value = var.database_name
}
