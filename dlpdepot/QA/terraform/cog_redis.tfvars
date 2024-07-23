region = "eu-central-1"

project_environment = { "env" : "dlp-qa" }

environment_scope = "QA-EU"

URL = "https://codehub.mitsogo.com/api/v4/projects/"

dlp-PROJECT_ID = 592

azure-PROJECT_ID = 593

workflow-PROJECT_ID = 591




########### COG Redis

replication_group_id = "cog-dlp-qa"

redis_num_node_groups = 1

redis_replicas_per_node_group = 3

redis_engine = "redis"

redis_engine_version = "7.1"

redis_apply_immediately = "true"

redis_automatic_failover_enabled = false

redis_multi_az_enabled = false

redis_node_type = "cache.t2.micro"

redis_subnet_ids = ["subnet-091e7ee1e4021962d", "subnet-020a5026628c0d2d4", "subnet-07cc4552d1ac64e49"]

redis_pg_name = "cog-dlp-qa"

redis_family = "redis7"

vpc_id = "vpc-09d8dd90e9c548ad0"

sg_source = ["192.168.0.0/16"]

redis_sg_name = "cog-dlp-qa"

security_group_name = "cog-dlp-qa"




############# Cloudwatch Logs 

log_group_name = "redis-dlp-qa-cog"
