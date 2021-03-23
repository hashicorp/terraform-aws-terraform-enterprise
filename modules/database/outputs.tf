output "db_endpoint" {
  value = aws_db_instance.postgresql.endpoint
}

output "db_name" {
  value = aws_db_instance.postgresql.name
}

output "db_password" {
  value = aws_db_instance.postgresql.password
}

output "db_username" {
  value = aws_db_instance.postgresql.username
}
