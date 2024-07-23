output "rds_address" {
  value = module.ms.rds_address
}

output "rds_username" {
  value     = module.ms.rds_username
  sensitive = true
}

output "rds_password" {
  value     = module.ms.rds_password
  sensitive = true
}

output "redis_address" {
  value = module.ms.redis_address
}