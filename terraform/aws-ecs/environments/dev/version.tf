# ==========================================================================
# TERRAFORM & PROVIDER VERSION CONSTRAINTS
# ==========================================================================
terraform {

  # Enforces minimum modern Terraform CLI version
  required_version = ">= 1.14.0"

  required_providers {
    # AWS Provider for managing the underlying RDS Infrastructure
    aws = {
      source = "hashicorp/aws"
      # Allows non-breaking upgrades within AWS Provider v6.x
      version = "~> 6.45.0"
    }

    # PostgreSQL Provider for connecting to RDS and managing internal DB objects
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.26.0"
    }
  }
}
