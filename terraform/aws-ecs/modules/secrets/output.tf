
output "secret_arn" {
  description = "Secrets Manager secret ARN"
  value       = aws_secretsmanager_secret.app_secrets.arn
}

output "secret_name" {
  description = "Secrets Manager secret name"
  value       = aws_secretsmanager_secret.app_secrets.name
}

output "ecs_secret_references" {
  description = "ECS container secret references keyed by secret JSON key"
  value       = { for key in keys(nonsensitive(var.secret_values)) : key => "${aws_secretsmanager_secret.app_secrets.arn}:${key}::" }
}

output "secret_values" {
  description = "Sensitive secret values keyed by JSON key for Terraform-managed resources that require direct values"
  value       = var.secret_values
  sensitive   = true
}
