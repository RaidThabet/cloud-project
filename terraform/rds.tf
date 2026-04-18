# PostgreSQL RDS instance and subnet group in private subnets.
module "database" {
  source = "./modules/database"

  project_name         = var.project_name
  private_subnet_ids   = module.network.private_subnet_ids
  rds_sg_id            = module.security.rds_sg_id
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  db_engine_version    = var.db_engine_version
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_port              = var.db_port
  tags                 = local.common_tags
}
