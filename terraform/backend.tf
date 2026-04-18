# Backend EC2 resources (Launch Template, ASG, scaling policy) and ALB are created by the backend module.
module "backend" {
  source = "./modules/backend"

  project_name               = var.project_name
  vpc_id                     = module.network.vpc_id
  public_subnet_ids          = module.network.public_subnet_ids
  private_subnet_ids         = module.network.private_subnet_ids
  alb_sg_id                  = module.security.alb_sg_id
  backend_sg_id              = module.security.backend_sg_id
  ami_id                     = local.selected_ami_id
  backend_instance_type      = var.backend_instance_type
  backend_app_port           = var.backend_app_port
  backend_health_check_path  = var.backend_health_check_path
  github_repo_url            = var.github_repo_url
  db_address                 = module.database.address
  db_port                    = module.database.port
  db_name                    = module.database.db_name
  db_username                = module.database.username
  db_password                = var.db_password
  backend_asg_min_size       = var.backend_asg_min_size
  backend_asg_desired_size   = var.backend_asg_desired_size
  backend_asg_max_size       = var.backend_asg_max_size
  backend_cpu_target_percent = var.backend_cpu_target_percent
  tags                       = local.common_tags
}
