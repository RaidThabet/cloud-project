
output "address" {
  description = "RDS endpoint hostname"
  value       = aws_db_instance.postgres.address
}

output "port" {
  description = "RDS endpoint port"
  value       = aws_db_instance.postgres.port
}

output "db_name" {
  description = "Database name configured on RDS"
  value       = aws_db_instance.postgres.db_name
}

output "username" {
  description = "Master username configured on RDS"
  value       = aws_db_instance.postgres.username
}
