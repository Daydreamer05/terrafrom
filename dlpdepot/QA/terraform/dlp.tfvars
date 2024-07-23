environment_scope = "QA-EU"

project_environment = { "env" : "dlp-qa" }

URL = "https://codehub.mitsogo.com/api/v4/projects/"

dlp-PROJECT_ID = 592

azure-PROJECT_ID = 593

workflow-PROJECT_ID = 591

region = "eu-central-1"



########### RDS Instance

rds_secret_name = "rds-dlp-qa"

app_specific_secret_name = "app-dlp-qa"

vpc_id = "vpc-09d8dd90e9c548ad0"

sg_source = ["192.168.0.0/16"]

security_group_name = "dlp-qa"

rds_sg_name = "dlp-qa"

db_name = "dlp"

redis_sg_name = "dlp-qa"

rds_subnet_ids = ["subnet-091e7ee1e4021962d", "subnet-020a5026628c0d2d4", "subnet-07cc4552d1ac64e49"]

rds_pg_name = "dlp-qa"

rds_postgres_family = "postgres15"

rds_identifier = "dlp-qa"

rds_instance_class = "db.t3.micro"

rds_allocated_storage = "50"

rds_engine_version = "15.5"

rds_publicly_accessible = "false"

rds_storage_type = "gp2"





############## REDIS

replication_group_id = "dlp-qa"

redis_num_node_groups = 1

redis_replicas_per_node_group = 3

redis_engine = "redis"

redis_engine_version = "7.1"

redis_apply_immediately = "true"

redis_automatic_failover_enabled = false

redis_multi_az_enabled = false

redis_node_type = "cache.t2.micro"

redis_subnet_ids = ["subnet-091e7ee1e4021962d", "subnet-020a5026628c0d2d4", "subnet-07cc4552d1ac64e49"]

redis_pg_name = "dlp-qa"

redis_family = "redis7"





############# Cloudwatch Logs 

log_group_name = "redis-dlp-qa"
