# ==========================================================================
# PUBLIC APPLICATION LOAD BALANCER SECURITY GROUP OUTPUTS
# ==========================================================================
output "alb_security_group_id" {
  description = "The ID of the Public ALB security group"
  value       = aws_security_group.alb.id
}

output "alb_security_group_arn" {
  description = "The ARN of the Public ALB security group"
  value       = aws_security_group.alb.arn
}

output "alb_security_group_name" {
  description = "The name of the Public ALB security group"
  value       = aws_security_group.alb.name
}


# ==========================================================================
# ECS MICROSERVICES SECURITY GROUP OUTPUTS
# ==========================================================================
output "ecs_apps_security_group_id" {
  description = "The ID of the ECS applications security group"
  value       = aws_security_group.ecs_apps.id
}

output "ecs_apps_security_group_arn" {
  description = "The ARN of the ECS applications security group"
  value       = aws_security_group.ecs_apps.arn
}

output "ecs_apps_security_group_name" {
  description = "The name of the ECS applications security group"
  value       = aws_security_group.ecs_apps.name
}


# ==========================================================================
# INTERNAL BROKERS SECURITY GROUP OUTPUTS
# ==========================================================================
output "brokers_security_group_id" {
  description = "The ID of the Internal Brokers security group"
  value       = aws_security_group.brokers.id
}

output "brokers_security_group_arn" {
  description = "The ARN of the Internal Brokers security group"
  value       = aws_security_group.brokers.arn
}

output "brokers_security_group_name" {
  description = "The name of the Internal Brokers security group"
  value       = aws_security_group.brokers.name
}
