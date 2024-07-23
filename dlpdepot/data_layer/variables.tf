variable "environment_scope" {
  type = string
}

variable "project_environment" {
  type = map(string)
}

variable "GITLAB_TOKEN" {
  type = string
}

variable "URL" {
  type = string
}

variable "dlp-PROJECT_ID" {
  type = string
}

variable "azure-PROJECT_ID" {
  type = string
}

variable "workflow-PROJECT_ID" {
  type = string
}

variable "region" {
  type = string
}




############  RDS Instance

variable "rds_secret_name" {
  type = string
}

variable "app_specific_secret_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "sg_source" {
  type = list(string)
}

variable "rds_sg_name" {
  type = string
}

variable "redis_sg_name" {
  type = string
}

variable "security_group_name" {
  type = string
}

variable "rds_subnet_ids" {
  type = list(string)
}

variable "db_name" {
  type = string
}

variable "rds_pg_name" {
  type = string
}

variable "rds_postgres_family" {
  type = string
}

variable "rds_identifier" {
  type = string
}

variable "rds_instance_class" {
  type = string
}

variable "rds_allocated_storage" {
  type = string
}

variable "rds_engine_version" {
  type = string
}

variable "rds_publicly_accessible" {
  type = bool
}

variable "rds_storage_type" {
  type = string
}



############   REDIS

variable "replication_group_id" {
  type = string
}

variable "redis_num_node_groups" {
  type = number
}

variable "redis_replicas_per_node_group" {
  type = number
}

variable "redis_engine" {
  type = string
}


variable "redis_engine_version" {
  type = string
}

variable "redis_apply_immediately" {
  type = bool
}

variable "redis_automatic_failover_enabled" {
  type = bool
}

variable "redis_multi_az_enabled" {
  type = bool
}


variable "redis_node_type" {
  type = string
}


variable "redis_subnet_ids" {
  type = list(string)
}

variable "redis_pg_name" {
  type = string
}

variable "redis_family" {
  type = string
}




######## Cloudwatch Logs 

variable "log_group_name" {
  type = string
}
