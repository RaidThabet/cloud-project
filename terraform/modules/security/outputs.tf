
output "alb_sg_id" {
  description = "Security group ID for ALB"
  value       = aws_security_group.alb_sg.id
}

output "backend_sg_id" {
  description = "Security group ID for backend ASG instances"
  value       = aws_security_group.backend_sg.id
}

output "rds_sg_id" {
  description = "Security group ID for PostgreSQL RDS"
  value       = aws_security_group.rds_sg.id
}

output "frontend_sg_id" {
  description = "Security group ID for frontend EC2"
  value       = aws_security_group.frontend_sg.id
}
