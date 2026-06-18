# ==========================================================================
# PROVIDER CONFIGURATION
# ==========================================================================
# AWS
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


provider "postgresql" {
  host            = module.stateful_infra.postgres_address
  port            = 5432
  username        = var.postgres_username
  password        = var.postgres_password
  sslmode         = "require"
  connect_timeout = 15

  # Connects to the initial default database created by AWS
  database        = module.stateful_infra.postgres_database_name
}

