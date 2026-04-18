variable "project_name" {
  description = "Project tag/name prefix applied to all resources"
  type        = string
  default     = "cloud-project"
}

variable "aws_region" {
  description = "AWS region where all resources are deployed"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zone_a" {
  description = "Primary availability zone"
  type        = string
  default     = "us-east-1a"
}

variable "availability_zone_b" {
  description = "Secondary availability zone"
  type        = string
  default     = "us-east-1b"
}

variable "public_subnet_a_cidr" {
  description = "CIDR for public subnet in AZ A"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_b_cidr" {
  description = "CIDR for public subnet in AZ B"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_a_cidr" {
  description = "CIDR for private subnet in AZ A"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_b_cidr" {
  description = "CIDR for private subnet in AZ B"
  type        = string
  default     = "10.0.4.0/24"
}

variable "backend_instance_type" {
  description = "EC2 instance type for backend Auto Scaling Group"
  type        = string
  default     = "t2.micro"
}

variable "frontend_instance_type" {
  description = "EC2 instance type for frontend instance"
  type        = string
  default     = "t2.micro"
}

variable "backend_app_port" {
  description = "Backend application listening port"
  type        = number
  default     = 3000
}

variable "backend_health_check_path" {
  description = "HTTP health check path for backend target group"
  type        = string
  default     = "/health"
}

variable "backend_asg_min_size" {
  description = "Minimum number of backend instances"
  type        = number
  default     = 2
}

variable "backend_asg_desired_size" {
  description = "Desired number of backend instances"
  type        = number
  default     = 2
}

variable "backend_asg_max_size" {
  description = "Maximum number of backend instances"
  type        = number
  default     = 4
}

variable "backend_cpu_target_percent" {
  description = "Target average CPU utilization percentage for scaling"
  type        = number
  default     = 70
}

variable "db_name" {
  description = "Database name for PostgreSQL instance"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master username for PostgreSQL instance"
  type        = string
  default     = "appadmin"
}

variable "db_password" {
  description = "Master password for PostgreSQL instance"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "PostgreSQL TCP port"
  type        = number
  default     = 5432
}

variable "db_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "16"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GiB"
  type        = number
  default     = 20
}

variable "github_repo_url" {
  description = "Git repository URL containing frontend and backend folders"
  type        = string
  # TODO: Replace this placeholder with your actual application repository URL.
  default = "https://github.com/RaidThabet/cloud-project"
}

variable "ubuntu_ami_owner" {
  description = "Owner account ID for Ubuntu AMIs"
  type        = string
  default     = "099720109477"
}

variable "ubuntu_ami_name_pattern" {
  description = "Name filter used to discover the latest Ubuntu 24.04 AMI"
  type        = string
  default     = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
}

variable "ubuntu_ami_id_override" {
  description = "Optional static AMI ID override; when null, latest Ubuntu 24.04 is used"
  type        = string
  default     = null
}

variable "github_sha" {
  description = "Commit SHA to trigger instance replacement via user_data updates"
  type        = string
  default     = "latest"
}
