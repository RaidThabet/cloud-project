# Frontend EC2 instance in a public subnet serving static files through NGINX.
module "frontend" {
  source = "./modules/frontend"

  project_name           = var.project_name
  ami_id                 = local.selected_ami_id
  frontend_instance_type = var.frontend_instance_type
  public_subnet_id       = module.network.public_subnet_ids[0]
  frontend_sg_id         = module.security.frontend_sg_id
  github_repo_url        = var.github_repo_url
  alb_dns_name           = module.backend.alb_dns
  github_sha             = var.github_sha
  tags                   = local.common_tags
}
