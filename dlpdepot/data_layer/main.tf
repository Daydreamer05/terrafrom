provider "aws" {
  region = var.region
}


terraform {
  required_version = ">= 1.0.0"
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.53.0" // Update version regularly
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2" // Update version regularly
    }
  }
}



module "ms" {
  source                           = "../modules/database"
  dlp-PROJECT_ID                   = var.dlp-PROJECT_ID
  azure-PROJECT_ID                 = var.azure-PROJECT_ID
  workflow-PROJECT_ID              = var.workflow-PROJECT_ID
  URL                              = var.URL
  environment_scope                = var.environment_scope
  GITLAB_TOKEN                     = var.GITLAB_TOKEN
  rds_secret_name                  = var.rds_secret_name
  app_specific_secret_name         = var.app_specific_secret_name
  vpc_id                           = var.vpc_id
  sg_source                        = var.sg_source
  rds_sg_name                      = var.rds_sg_name
  db_name                          = var.db_name
  rds_subnet_ids                   = var.rds_subnet_ids
  rds_pg_name                      = var.rds_pg_name
  rds_postgres_family              = var.rds_postgres_family
  rds_identifier                   = var.rds_identifier
  rds_instance_class               = var.rds_instance_class
  rds_allocated_storage            = var.rds_allocated_storage
  rds_engine_version               = var.rds_engine_version
  rds_publicly_accessible          = var.rds_publicly_accessible
  rds_storage_type                 = var.rds_storage_type
  replication_group_id             = var.replication_group_id
  redis_sg_name                    = var.redis_sg_name
  redis_num_node_groups            = var.redis_num_node_groups
  redis_replicas_per_node_group    = var.redis_replicas_per_node_group
  redis_engine                     = var.redis_engine
  redis_engine_version             = var.redis_engine_version
  redis_apply_immediately          = var.redis_apply_immediately
  redis_automatic_failover_enabled = var.redis_automatic_failover_enabled
  redis_multi_az_enabled           = var.redis_multi_az_enabled
  redis_node_type                  = var.redis_node_type
  redis_subnet_ids                 = var.redis_subnet_ids
  redis_pg_name                    = var.redis_pg_name
  redis_family                     = var.redis_family
  project_environment              = var.project_environment
  security_group_name              = var.security_group_name
  log_group_name                   = var.log_group_name
}

