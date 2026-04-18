variable "project_name" {
  description = "Project identifier for naming and tagging"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups are created"
  type        = string
}

variable "backend_app_port" {
  description = "Backend application port allowed from ALB to backend SG"
  type        = number
}

variable "db_port" {
  description = "PostgreSQL port allowed from backend SG to RDS SG"
  type        = number
}

variable "tags" {
  description = "Common tags applied to security resources"
  type        = map(string)
  default     = {}
}