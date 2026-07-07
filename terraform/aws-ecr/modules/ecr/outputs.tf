output "registry_url" {
  description = "The ECR registry URL (AWS account ID)"
  value       = data.aws_caller_identity.current.account_id
}

output "repository_urls" {
  description = "Map of repository names to their full ECR URLs (without image tag)"
  value = {
    for name, repo in aws_ecr_repository.repos :
    name => repo.repository_url
  }
}

output "repository_arns" {
  description = "Map of repository names to their ARNs"
  value = {
    for name, repo in aws_ecr_repository.repos :
    name => repo.arn
  }
}

output "repository_names" {
  description = "Map of repository names to their actual AWS ECR repository names"
  value = {
    for name, repo in aws_ecr_repository.repos :
    name => repo.name
  }
}

# Data source to fetch current AWS account ID
data "aws_caller_identity" "current" {}

