
variable "project_name" {
  description = "Project identifier for naming and tagging"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "Two public subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnets" {
  description = "Two private subnet CIDR blocks"
  type        = list(string)
}

variable "azs" {
  description = "Two availability zones used by the deployment"
  type        = list(string)
}

variable "tags" {
  description = "Common tags applied to network resources"
  type        = map(string)
  default     = {}
}
