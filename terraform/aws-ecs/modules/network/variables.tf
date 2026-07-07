# =============================================================================
# Terraform Network Module Variables
# =============================================================================

variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "springservice"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "springservice"
    ManagedBy   = "terraform"
  }
}

# =============================================================================
# VPC ENDPOINTS CONFIGURATION
# =============================================================================

variable "enable_s3_endpoint" {
  description = "Enable S3 VPC Gateway endpoint"
  type        = bool
  default     = true
}

variable "enable_dynamodb_endpoint" {
  description = "Enable DynamoDB VPC Gateway endpoint"
  type        = bool
  default     = false
}

variable "enable_ecr_endpoints" {
  description = "Enable ECR API and DKR VPC Interface endpoints"
  type        = bool
  default     = true
}

variable "enable_logs_endpoint" {
  description = "Enable CloudWatch Logs VPC Interface endpoint"
  type        = bool
  default     = true
}
