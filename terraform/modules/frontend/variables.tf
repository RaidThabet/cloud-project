
variable "project_name" {
  description = "Project identifier for naming and tagging"
  type        = string
}

variable "ami_id" {
  description = "AMI ID used by frontend EC2 instance"
  type        = string
}

variable "frontend_instance_type" {
  description = "EC2 instance type for frontend"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID where frontend instance is launched"
  type        = string
}

variable "frontend_sg_id" {
  description = "Security group ID attached to frontend instance"
  type        = string
}

variable "alb_dns_name" {
  description = "ALB DNS name used by frontend JavaScript as backend endpoint"
  type        = string
}

variable "github_repo_url" {
  description = "Git repository URL that contains frontend source code"
  type        = string
}

variable "tags" {
  description = "Common tags applied to frontend resources"
  type        = map(string)
  default     = {}
}

variable "github_sha" {
  description = "Commit SHA to trigger instance replacement via user_data updates"
  type        = string
}
