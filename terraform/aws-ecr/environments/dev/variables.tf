variable "aws_region" {
  description = "AWS region for ECR repositories"
  type        = string
  default     = "ca-central-1"
}


variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "springservice"
}

# Credentials passed securely from your .tfvars file
variable "dockerhub_username" {
  type        = string
  description = "Docker Hub Username"
}

variable "dockerhub_password" {
  type        = string
  description = "Docker Hub Access Token or Password"
  sensitive   = true
}

