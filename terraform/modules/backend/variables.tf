
variable "project_name" {
  description = "Project identifier for naming and tagging"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for ALB target group"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB placement"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for backend ASG placement"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Security group ID for ALB"
  type        = string
}

variable "backend_sg_id" {
  description = "Security group ID for backend instances"
  type        = string
}

variable "ami_id" {
  description = "AMI ID used by backend launch template"
  type        = string
}

variable "backend_instance_type" {
  description = "Backend EC2 instance type"
  type        = string
}

variable "backend_app_port" {
  description = "Backend application port"
  type        = number
}

variable "backend_health_check_path" {
  description = "ALB target group health check path"
  type        = string
}

variable "github_repo_url" {
  description = "Git repository URL that contains backend source code"
  type        = string
}

variable "db_address" {
  description = "RDS endpoint hostname"
  type        = string
}

variable "db_port" {
  description = "RDS endpoint port"
  type        = number
}

variable "db_name" {
  description = "Database name used by backend"
  type        = string
}

variable "db_username" {
  description = "Database username used by backend"
  type        = string
}

variable "db_password" {
  description = "Database password used by backend"
  type        = string
  sensitive   = true
}

variable "backend_asg_min_size" {
  description = "Minimum ASG capacity"
  type        = number
}

variable "backend_asg_desired_size" {
  description = "Desired ASG capacity"
  type        = number
}

variable "backend_asg_max_size" {
  description = "Maximum ASG capacity"
  type        = number
}

variable "backend_cpu_target_percent" {
  description = "CPU target percentage for target-tracking policy"
  type        = number
}

variable "tags" {
  description = "Common tags applied to backend resources"
  type        = map(string)
  default     = {}
}
