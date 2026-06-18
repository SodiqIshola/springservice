
# ==========================================================================
# ECR REPOSITORIES MODULE
# ==========================================================================
module "ecr" {
  source = "../../modules/ecr"

  # Define all microservice repositories with their configurations
  repositories = {
    "customer" = {
      dockerhub_source_image  = "sunky24/customer-service:latest"
      image_tag               = "latest"
      scan_on_push            = true
      encryption_type         = "AES256"
      image_tag_mutability    = "MUTABLE"
      retention_days          = 30
    }
    "fraud" = {
      dockerhub_source_image  = "sunky24/fraud-service:latest"
      image_tag               = "latest"
      scan_on_push            = true
      encryption_type         = "AES256"
      image_tag_mutability    = "MUTABLE"
      retention_days          = 30
    }
    "eureka-server" = {
      dockerhub_source_image  = "sunky24/eureka-server:latest"
      image_tag               = "latest"
      scan_on_push            = true
      encryption_type         = "AES256"
      image_tag_mutability    = "MUTABLE"
      retention_days          = 30
    }
    "kafka-sms" = {
      dockerhub_source_image  = "sunky24/kafkasms-service:latest"
      image_tag               = "latest"
      scan_on_push            = true
      encryption_type         = "AES256"
      image_tag_mutability    = "MUTABLE"
      retention_days          = 30
    }
    "rabbitmq-sms" = {
      dockerhub_source_image  = "sunky24/rabbitmqsms-service:latest"
      image_tag               = "latest"
      scan_on_push            = true
      encryption_type         = "AES256"
      image_tag_mutability    = "MUTABLE"
      retention_days          = 30
    }
    "twilio-sms" = {
      dockerhub_source_image  = "sunky24/twilosms-service:latest"
      image_tag               = "latest"
      scan_on_push            = true
      encryption_type         = "AES256"
      image_tag_mutability    = "MUTABLE"
      retention_days          = 30
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = "platform-team"
    ManagedBy   = "terraform"
  }
}

