# =============================================================================
# GENERAL CONFIGURATION
# =============================================================================

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "springservice"
}

# =============================================================================
# NETWORK CONFIGURATION
# =============================================================================

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# =============================================================================
# VPC Interface & Gateway Endpoints Settings
# =============================================================================

variable "enable_s3_endpoint" {
  description = "Enable S3 VPC Gateway endpoint"
  type        = bool
  default     = false
}

variable "enable_dynamodb_endpoint" {
  description = "Enable DynamoDB VPC Gateway endpoint"
  type        = bool
  default     = false
}

variable "enable_ecr_endpoints" {
  description = "Enable ECR API and DKR VPC Interface endpoints"
  type        = bool
  default     = false
}

variable "enable_logs_endpoint" {
  description = "Enable CloudWatch Logs VPC Interface endpoint"
  type        = bool
  default     = false
}


# =============================================================================
# # Microservice Architectural Overrides Example
# =============================================================================
variable "service_overrides" {
  description = "Per-service ECS sizing, port, or extra environment variable overrides"
  type = map(object({
    cpu    = optional(number)
    memory = optional(number)
    port   = optional(number)
    env_vars = optional(list(object({
      name  = string
      value = string
    })), [])
  }))
  default = {}
}


# =============================================================================
# # PostgreSQL Database Configuration
# =============================================================================
variable "postgres_username" {
  description = "PostgreSQL master username"
  type        = string
  sensitive   = true
}

variable "postgres_password" {
  description = "PostgreSQL master password"
  type        = string
  sensitive   = true
}

variable "postgres_db_name" {
  description = "Default PostgreSQL database name"
  type        = string
  default     = "customer"
}

variable "fraud_db_name" {
  type        = string
  description = "The ID of the internal-brokers-sg security group"
  default     = "fraud"
}


variable "postgres_instance_class" {
  type        = string
  description = "RDS PostgreSQL instance class"
  default     = "db.t3.medium"
}

variable "postgres_allocated_storage" {
  type        = number
  description = "Initial RDS PostgreSQL storage in GiB"
  default     = 20
}

variable "postgres_max_allocated_storage" {
  type        = number
  description = "Maximum RDS PostgreSQL autoscaled storage in GiB"
  default     = 100
}



# =============================================================================
# # Apache Kafka (MSK) Configuration
# =============================================================================
variable "kafka_instance_type" {
  type        = string
  description = "MSK broker instance type"
  default     = "kafka.t3.small"
}

variable "kafka_broker_volume_size" {
  type        = number
  description = "EBS volume size in GiB for each MSK broker"
  default     = 50
}

# =============================================================================
# # RabbitMQ Configuration
# =============================================================================
variable "rmq_instance_type" {
  type        = string
  description = "Amazon MQ RabbitMQ instance type"
  default     = "mq.t3.micro"
}

variable "rmq_deployment_mode" {
  type        = string
  description = "Amazon MQ RabbitMQ deployment mode"
  default     = "SINGLE_INSTANCE"
}

variable "rmq_username" {
  description = "RabbitMQ broker username"
  type        = string
  sensitive   = true
}

variable "rmq_password" {
  description = "RabbitMQ broker password"
  type        = string
  sensitive   = true
}

# =============================================================================
# # Twilio API Credentials
# =============================================================================
variable "twilio_account_sid" {
  description = "Twilio account SID"
  type        = string
  sensitive   = true
}

variable "twilio_auth_token" {
  description = "Twilio auth token"
  type        = string
  sensitive   = true
}

variable "twilio_from_number" {
  description = "Twilio sender phone number"
  type        = string
  sensitive   = true
}










