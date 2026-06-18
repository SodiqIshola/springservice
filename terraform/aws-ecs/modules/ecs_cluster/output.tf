output "cluster_id" {
  description = "ECS cluster ID"
  value       = aws_ecs_cluster.main.id
}

output "cluster_arn" {
  description = "ECS cluster ARN"
  value       = aws_ecs_cluster.main.arn
}

output "service_names" {
  description = "ECS service names keyed by application name"
  value       = { for name, service in aws_ecs_service.apps : name => service.name }
}

output "task_definition_arns" {
  description = "ECS task definition ARNs keyed by application name"
  value       = { for name, task in aws_ecs_task_definition.apps : name => task.arn }
}

output "log_group_names" {
  description = "CloudWatch log group names keyed by application name"
  value       = { for name, log_group in aws_cloudwatch_log_group.apps : name => log_group.name }
}

output "service_connect_namespace_name" {
  description = "Service Connect Cloud Map namespace name"
  value       = aws_service_discovery_http_namespace.this.name
}

output "service_connect_namespace_arn" {
  description = "Service Connect Cloud Map namespace ARN"
  value       = aws_service_discovery_http_namespace.this.arn
}
