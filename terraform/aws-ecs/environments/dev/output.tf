# =============================================================================
# OUTPUTS
# =============================================================================

# VPC Information
output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.network.vpc_cidr_block
}

# Subnet Information
output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.network.private_subnet_ids
}

output "availability_zones" {
  description = "Availability zones"
  value       = module.network.availability_zones
}

# Network Summary
output "network_summary" {
  description = "Network configuration summary"
  value       = module.network.network_config
}

# Load Balancer
output "alb_dns_name" {
  description = "Public ALB DNS name"
  value       = module.public_alb.alb_dns_name
}

output "alb_target_group_arns" {
  description = "ALB target group ARNs keyed by service"
  value       = module.public_alb.target_group_arns
}

# ECS
output "ecs_cluster_arn" {
  description = "ECS cluster ARN"
  value       = module.ecs_cluster.cluster_arn
}

output "ecs_service_names" {
  description = "ECS service names keyed by application"
  value       = module.ecs_cluster.service_names
}

output "ecs_log_group_names" {
  description = "CloudWatch log group names keyed by application"
  value       = module.ecs_cluster.log_group_names
}

output "service_connect_namespace_name" {
  description = "Service Connect namespace name"
  value       = module.ecs_cluster.service_connect_namespace_name
}

output "service_connect_namespace_arn" {
  description = "Service Connect namespace ARN"
  value       = module.ecs_cluster.service_connect_namespace_arn
}

# Stateful dependencies
output "postgres_endpoint" {
  description = "PostgreSQL endpoint"
  value       = module.stateful_infra.postgres_endpoint
}

output "kafka_bootstrap_brokers" {
  description = "MSK bootstrap broker string"
  value       = module.stateful_infra.kafka_bootstrap_brokers
}

output "rabbitmq_endpoints" {
  description = "RabbitMQ endpoints"
  value       = module.stateful_infra.rabbitmq_endpoints
}

# Secrets
output "twilio_secret_name" {
  description = "Secrets Manager secret name for Twilio credentials"
  value       = module.twilio_secrets.secret_name
}

output "twilio_secret_arn" {
  description = "Secrets Manager secret ARN for Twilio credentials"
  value       = module.twilio_secrets.secret_arn
}

output "platform_secret_name" {
  description = "Secrets Manager secret name for PostgreSQL and RabbitMQ credentials"
  value       = module.platform_secrets.secret_name
}

output "platform_secret_arn" {
  description = "Secrets Manager secret ARN for PostgreSQL and RabbitMQ credentials"
  value       = module.platform_secrets.secret_arn
}

