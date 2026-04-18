
output "backend_alb_dns" {
  description = "DNS name of the backend Application Load Balancer"
  value       = module.backend.alb_dns
}

output "frontend_public_ip" {
  description = "Public IPv4 address of the frontend EC2 instance"
  value       = module.frontend.public_ip
}
