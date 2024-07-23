#########   Getting Passwords

data "aws_secretsmanager_secret" "secretsmanager_secret" {
  name = var.rds_secret_name
}

data "aws_secretsmanager_secret_version" "secret_credentials" {
  secret_id = data.aws_secretsmanager_secret.secretsmanager_secret.id
}

data "aws_secretsmanager_secret" "app_specific_db_secret" {
  name = var.app_specific_secret_name
}

data "aws_secretsmanager_secret_version" "app_specific_db_secret_credentials" {
  secret_id = data.aws_secretsmanager_secret.app_specific_db_secret.id
}

locals {
  master_username       = jsondecode(data.aws_secretsmanager_secret_version.secret_credentials.secret_string)["username"]
  master_password       = jsondecode(data.aws_secretsmanager_secret_version.secret_credentials.secret_string)["password"]
  app_specific_username = jsondecode(data.aws_secretsmanager_secret_version.app_specific_db_secret_credentials.secret_string)["username"]
  app_specific_password = jsondecode(data.aws_secretsmanager_secret_version.app_specific_db_secret_credentials.secret_string)["password"]
}


#########   RDS Instance

module "rds_sg" {
  source    = "../security_group/"
  vpc_id    = var.vpc_id
  sg_source = var.sg_source
  name      = "rds-${var.security_group_name}"
}

resource "aws_db_subnet_group" "rds_db_subnet_group" {
  name       = var.rds_sg_name
  subnet_ids = var.rds_subnet_ids
  tags       = var.project_environment
}

resource "aws_db_parameter_group" "rds_db_parameter_group" {
  name   = var.rds_pg_name
  family = var.rds_postgres_family
  parameter {
    name         = "rds.logical_replication"
    value        = "1"
    apply_method = "pending-reboot"
  }
  tags = var.project_environment
}


resource "aws_db_instance" "rds_db_instance" {
  identifier                      = var.rds_identifier
  db_name                         = var.db_name
  instance_class                  = var.rds_instance_class
  allocated_storage               = var.rds_allocated_storage
  username                        = local.master_username
  password                        = local.master_password
  engine                          = "postgres"
  engine_version                  = var.rds_engine_version
  publicly_accessible             = var.rds_publicly_accessible
  skip_final_snapshot             = false
  storage_type                    = var.rds_storage_type
  storage_encrypted               = true
  enabled_cloudwatch_logs_exports = ["postgresql"]
  db_subnet_group_name            = aws_db_subnet_group.rds_db_subnet_group.name
  parameter_group_name            = aws_db_parameter_group.rds_db_parameter_group.name
  vpc_security_group_ids          = [module.rds_sg.security_group_id]
  backup_retention_period         = 7
  apply_immediately               = true
  tags                            = var.project_environment
}


#########   REDIS


module "redis_sg" {
  source    = "../security_group/"
  vpc_id    = var.vpc_id
  from_port = "6379"
  to_port   = "6379"
  sg_source = var.sg_source
  name      = "redis-${var.security_group_name}"
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
  auto_minor_version_upgrade = false
  at_rest_encryption_enabled = true
  tags                       = var.project_environment
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



#########   Cloudwatch Logs

resource "aws_cloudwatch_log_group" "log_group" {
  name              = var.log_group_name
  retention_in_days = 3
  tags              = var.project_environment
}





#########   RDS details

resource "null_resource" "rds_details" {
  triggers = {
    value = aws_db_instance.rds_db_instance.address
  }
  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]
    command     = <<-EOF
      for project_id in "${var.dlp-PROJECT_ID}" "${var.azure-PROJECT_ID}" "${var.workflow-PROJECT_ID}"; do
        sh ${path.module}/vars_updation.sh '${var.GITLAB_TOKEN}' '${var.URL}' $project_id '${var.environment_scope}' 'DB_BOUNCER_HOST' '${aws_db_instance.rds_db_instance.address}'
        sh ${path.module}/vars_updation.sh '${var.GITLAB_TOKEN}' '${var.URL}' $project_id '${var.environment_scope}' 'DB_BOUNCER_USERNAME' '${local.app_specific_username}'
        sh ${path.module}/vars_updation.sh '${var.GITLAB_TOKEN}' '${var.URL}' $project_id '${var.environment_scope}' 'DB_BOUNCER_PASSWORD' '${local.app_specific_password}'
        sh ${path.module}/vars_updation.sh '${var.GITLAB_TOKEN}' '${var.URL}' $project_id '${var.environment_scope}' 'DB_BOUNCER_PORT' '${aws_db_instance.rds_db_instance.port}'
        sh ${path.module}/vars_updation.sh '${var.GITLAB_TOKEN}' '${var.URL}' $project_id '${var.environment_scope}' 'DEVOPS_DB_BOUNCER_HOST' '${aws_db_instance.rds_db_instance.address}'
        sh ${path.module}/vars_updation.sh '${var.GITLAB_TOKEN}' '${var.URL}' $project_id '${var.environment_scope}' 'DEVOPS_DB_BOUNCER_USERNAME' '${local.master_username}'
        sh ${path.module}/vars_updation.sh '${var.GITLAB_TOKEN}' '${var.URL}' $project_id '${var.environment_scope}' 'DEVOPS_DB_BOUNCER_PASSWORD' '${local.master_password}'
        sh ${path.module}/vars_updation.sh '${var.GITLAB_TOKEN}' '${var.URL}' $project_id '${var.environment_scope}' 'DEVOPS_DB_BOUNCER_PORT' '${aws_db_instance.rds_db_instance.port}'
        sh ${path.module}/vars_updation.sh '${var.GITLAB_TOKEN}' '${var.URL}' $project_id '${var.environment_scope}' 'DATABASE_URI' 'postgresql://${aws_db_instance.rds_db_instance.username}:${aws_db_instance.rds_db_instance.password}@${aws_db_instance.rds_db_instance.address}/cog'
      done
  EOF
  }
}


#########   Redis details

resource "null_resource" "redis_details" {
  triggers = {
    value = aws_elasticache_replication_group.elasticache_replication_group.primary_endpoint_address
  }
  provisioner "local-exec" {
    interpreter = ["sh", "-c"]
    command     = <<-EOF
      for project_id in "${var.dlp-PROJECT_ID}" "${var.azure-PROJECT_ID}" "${var.workflow-PROJECT_ID}"; do
        sh ${path.module}/vars_updation.sh '${var.GITLAB_TOKEN}' '${var.URL}' $project_id '${var.environment_scope}' 'ELASTICACHE_HOST' '${aws_elasticache_replication_group.elasticache_replication_group.primary_endpoint_address}'
        sh ${path.module}/vars_updation.sh '${var.GITLAB_TOKEN}' '${var.URL}' $project_id '${var.environment_scope}' 'ELASTICACHE_PORT' '${aws_elasticache_replication_group.elasticache_replication_group.port}'
      done
    EOF
  }
}
