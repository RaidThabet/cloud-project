
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure AWS provider for the selected deployment region.
provider "aws" {
  region = var.aws_region
}

# Query the latest Ubuntu 24.04 LTS AMI dynamically to avoid hardcoded AMI IDs.
data "aws_ami" "ubuntu_2404" {
  most_recent = true
  owners      = [var.ubuntu_ami_owner]

  filter {
    name   = "name"
    values = [var.ubuntu_ami_name_pattern]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  # Shared tags applied consistently across supported resources.
  common_tags = {
    Name    = var.project_name
    Project = var.project_name
  }

  # Allow optional AMI override; fallback to latest Ubuntu 24.04 data source.
  selected_ami_id = coalesce(var.ubuntu_ami_id_override, data.aws_ami.ubuntu_2404.id)
}
