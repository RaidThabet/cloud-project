# Core networking stack (VPC, subnets, IGW, NAT Gateway, and route tables).
module "network" {
  source = "./modules/network"

  project_name    = var.project_name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = [var.public_subnet_a_cidr, var.public_subnet_b_cidr]
  private_subnets = [var.private_subnet_a_cidr, var.private_subnet_b_cidr]
  azs             = [var.availability_zone_a, var.availability_zone_b]
  tags            = local.common_tags
}
