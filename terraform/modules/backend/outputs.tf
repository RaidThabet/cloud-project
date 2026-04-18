
output "alb_dns" {
  description = "DNS name of backend ALB"
  value       = aws_lb.alb.dns_name
}
