# ==========================================================================
# TERRAFORM & PROVIDER VERSION CONSTRAINTS
# ==========================================================================
terraform {

  # Enforces minimum modern Terraform CLI version
  required_version = ">= 1.14.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # Allows non-breaking upgrades within AWS Provider v6.x
      version = "~> 6.45.0"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 4.3"
    }

  }
}

