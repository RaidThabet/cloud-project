
variable "project_name" {
  description = "Project identifier for naming and tagging"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by DB subnet group"
  type        = list(string)
}

variable "rds_sg_id" {
  description = "Security group ID attached to RDS instance"
  type        = string
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
}

variable "db_username" {
  description = "PostgreSQL master username"
  type        = string
}

variable "db_password" {
  description = "PostgreSQL master password"
  type        = string
  sensitive   = true
}

variable "db_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated storage in GiB"
  type        = number
}

variable "db_port" {
  description = "PostgreSQL port"
  type        = number
}

variable "tags" {
  description = "Common tags applied to database resources"
  type        = map(string)
  default     = {}
}
