output "registry_url" {
  description = "AWS ECR registry URL prefix (account-id.dkr.ecr.region.amazonaws.com)"
  value       = "${module.ecr.registry_url}.dkr.ecr.${var.aws_region}.amazonaws.com"
}

output "repository_urls" {
  description = "Map of service names to their full ECR repository URLs"
  value       = module.ecr.repository_urls
}

output "repository_arns" {
  description = "Map of service names to their ECR repository ARNs"
  value       = module.ecr.repository_arns
}

output "repository_names" {
  description = "Map of service names to their ECR repository names"
  value       = module.ecr.repository_names
}


