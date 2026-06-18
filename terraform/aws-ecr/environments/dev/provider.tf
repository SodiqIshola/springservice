# ==========================================================================
# PROVIDER CONFIGURATION
# ==========================================================================
# Fetch temporary ECR login credentials from AWS
data "aws_ecr_authorization_token" "token" {}

# AWS provider settings
provider "aws" {
  region  = var.aws_region
  profile = "tf-project"

  # Automatically tags every resource created by this provider
  default_tags {
    tags = {
      Environment = "Development"
      Project     = "Node-Fargate-OTel"
      ManagedBy   = "Terraform"
    }
  }
}


provider "docker" {
  # Authenticate to target AWS ECR Registry
  registry_auth {
    address  = data.aws_ecr_authorization_token.token.proxy_endpoint
    username = data.aws_ecr_authorization_token.token.user_name  # Changed from userName
    password = data.aws_ecr_authorization_token.token.password   # Verify this is lowercase
  }

  # Authenticate to source Docker Hub
  registry_auth {
    address  = "registry-1.docker.io"
    username = var.dockerhub_username
    password = var.dockerhub_password
  }
}
