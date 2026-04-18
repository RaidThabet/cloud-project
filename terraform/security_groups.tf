# Layered security groups with strict least-privilege ingress rules.
module "security" {
  source = "./modules/security"

  project_name     = var.project_name
  vpc_id           = module.network.vpc_id
  backend_app_port = var.backend_app_port
  db_port          = var.db_port
  tags             = local.common_tags
}
