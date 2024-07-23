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



#########   Cloudwatch Logs

resource "aws_cloudwatch_log_group" "log_group" {
  name              = var.log_group_name
  retention_in_days = 3
  tags              = var.project_environment
}




########  COG Redis

module "redis_sg" {
  source    = "../modules/security_group/"
  vpc_id    = var.vpc_id
  from_port = "6379"
  to_port   = "6379"
  sg_source = var.sg_source
  name      = var.security_group_name
}


resource "aws_elasticache_replication_group" "elasticache_replication_group" {
  replication_group_id       = var.replication_group_id
  port                       = 6379
  description                = "redis"
  security_group_ids         = [module.redis_sg.security_group_id]
  subnet_group_name          = aws_elasticache_subnet_group.subnet_group.name
  parameter_group_name       = aws_elasticache_parameter_group.parameter_group.name
  num_node_groups            = var.redis_num_node_groups
  replicas_per_node_group    = var.redis_replicas_per_node_group
  engine                     = var.redis_engine
  engine_version             = var.redis_engine_version
  apply_immediately          = var.redis_apply_immediately
  automatic_failover_enabled = var.redis_automatic_failover_enabled
  multi_az_enabled           = var.redis_multi_az_enabled
  node_type                  = var.redis_node_type
  tags                       = var.project_environment
  at_rest_encryption_enabled = true
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.log_group.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }
}


resource "aws_elasticache_subnet_group" "subnet_group" {
  name       = var.redis_sg_name
  subnet_ids = var.redis_subnet_ids
  tags       = var.project_environment
}

resource "aws_elasticache_parameter_group" "parameter_group" {
  name   = var.redis_pg_name
  family = var.redis_family
  tags   = var.project_environment
}





########  COG Redis Details

resource "null_resource" "cog_redis_details" {
  triggers = {
    value = aws_elasticache_replication_group.elasticache_replication_group.primary_endpoint_address
  }
  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]
    command     = <<-EOF
      for project_id in "${var.dlp-PROJECT_ID}" "${var.azure-PROJECT_ID}" "${var.workflow-PROJECT_ID}"; do
        sh ${path.module}/vars_updation.sh '${var.GITLAB_TOKEN}' '${var.URL}' $project_id '${var.environment_scope}' 'BROKER_URI' 'redis://${aws_elasticache_replication_group.elasticache_replication_group.primary_endpoint_address}/1'
        sh ${path.module}/vars_updation.sh '${var.GITLAB_TOKEN}' '${var.URL}' $project_id '${var.environment_scope}' 'RESULT_BACKEND_URI' 'redis://${aws_elasticache_replication_group.elasticache_replication_group.primary_endpoint_address}/2'
      done
    EOF
  }
}
