# ==========================================================================
# DATA SOURCES
# ==========================================================================
data "aws_ecr_repository" "microservices" {
  for_each = local.migrated_services
  name     = each.value
}

# NOTE: Note needed if the image is guarantee to be available in ecr
# Ensures deployment safety: Terraform will immediately fail and block
# the apply step if the ':latest' image tag is missing from ECR.
data "aws_ecr_image" "apps" {
  for_each        = local.migrated_services
  repository_name = data.aws_ecr_repository.microservices[each.key].name
  image_tag       = "latest"
}




# =============================================================================
# NETWORK MODULE
# =============================================================================
module "network" {
  source = "../../modules/network"

  # Basic configuration
  name_prefix = var.name_prefix
  vpc_cidr    = var.vpc_cidr
  aws_region  = var.aws_region

  # Custom tags
  tags = {
    Environment = "dev"
    Project     = "springservice"
    Owner       = "platform-team"
  }

  # Enable basic VPC endpoints
  enable_s3_endpoint       = var.enable_s3_endpoint
  enable_ecr_endpoints     = var.enable_ecr_endpoints
  enable_logs_endpoint     = var.enable_logs_endpoint
  enable_dynamodb_endpoint = var.enable_dynamodb_endpoint
}

// =============================================================================
// SECURITY GROUPS
// =============================================================================
module "security_groups" {
  source      = "../../modules/security_group"
  name_prefix = var.name_prefix
  vpc_id      = module.network.vpc_id

  tags = {
    Environment = "dev"
    Project     = "springservice"
  }
  vpc_cidr_block = var.vpc_cidr
}

// =============================================================================
// PUBLIC ALB
// =============================================================================
module "public_alb" {
  source                = "../../modules/public_alb"
  name_prefix           = var.name_prefix
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id
  exposed_services      = local.exposed_services

  tags = {
    Environment = "dev"
    Project     = "springservice"
  }
}

# =============================================================================
# APPLICATION SECRETS
# =============================================================================
module "twilio_secrets" {
  source      = "../../modules/secrets"
  name_prefix = var.name_prefix
  name        = "twilio-sms"

  secret_values = {
    TWILIO_ACCOUNT_SID = var.twilio_account_sid
    TWILIO_AUTH_TOKEN  = var.twilio_auth_token
    TWILIO_FROM_NUMBER = var.twilio_from_number
  }

  tags = {
    Environment = "dev"
    Project     = "springservice"
    Service     = "twilio-sms"
  }
}

module "platform_secrets" {
  source      = "../../modules/secrets"
  name_prefix = var.name_prefix
  name        = "platform"

  secret_values = {
    POSTGRES_USERNAME = var.postgres_username
    POSTGRES_PASSWORD = var.postgres_password
    RABBITMQ_USERNAME = var.rmq_username
    RABBITMQ_PASSWORD = var.rmq_password
  }

  tags = {
    Environment = "dev"
    Project     = "springservice"
    Service     = "platform"
  }
}


# ==========================================================================
# STATEFUL DATA LAYER INFRASTRUCTURE
# ==========================================================================
module "stateful_infra" {
  source = "../../modules/stateful-infra"

  # Core Networking & Security Contracts
  name_prefix = var.name_prefix
  brokers_security_group_id = module.security_groups.brokers_security_group_id

  # Extracts the first private subnet string explicitly to guarantee RabbitMQ compatibility
  private_subnet_ids = module.network.private_subnet_ids

  # Database Engine Access Profiles
  postgres_db_name           = var.postgres_db_name
  postgres_username          = module.platform_secrets.secret_values["POSTGRES_USERNAME"]
  postgres_password          = module.platform_secrets.secret_values["POSTGRES_PASSWORD"]
  postgres_instance_class    = var.postgres_instance_class
  postgres_allocated_storage = var.postgres_allocated_storage
  postgres_max_allocated_storage = var.postgres_max_allocated_storage

  # Messaging & Event Broker Engine Sizing Profiles
  rmq_instance_type   = var.rmq_instance_type
  rmq_deployment_mode = var.rmq_deployment_mode
  rmq_username        = module.platform_secrets.secret_values["RABBITMQ_USERNAME"]
  rmq_password        = module.platform_secrets.secret_values["RABBITMQ_PASSWORD"]
  kafka_instance_type = var.kafka_instance_type
  kafka_broker_volume_size = var.kafka_broker_volume_size

  # Global Tag Alignment
  tags = {
    Environment = "dev"
    Project     = "springservice"
  }
  fraud_db_name = var.fraud_db_name
}



// =============================================================================
// IAM ROLES
// =============================================================================
module "iam_roles" {
  source                      = "../../modules/iam_roles"
  msk_cluster_arn             = module.stateful_infra.kafka_cluster_arn
  name                        = var.name_prefix
  secrets_manager_secret_arns = [module.twilio_secrets.secret_arn]

  tags = {
    Environment = "dev"
    Project     = "springservice"
  }
}


// =============================================================================
// ECS CLUSTER
// =============================================================================
module "ecs_cluster" {
  source                     = "../../modules/ecs_cluster"
  app_configurations         = local.services_config
  ecs_apps_security_group_id = module.security_groups.ecs_apps_security_group_id
  execution_role_arn         = module.iam_roles.execution_role_arn
  private_subnet_ids         = module.network.private_subnet_ids
  target_group_arns          = module.public_alb.target_group_arns
  task_role_arn              = module.iam_roles.task_role_arn
  vpc_id                     = module.network.vpc_id
  name_prefix                = var.name_prefix

  tags = {
    Environment = "dev"
    Project     = "springservice"
  }
}
