# ==========================================================================
# CENTRAL MICROSERVICE SERVICE CATALOG & GENERATION ENGINE
# ==========================================================================

locals {
  # Single source of truth for all deployed microservices
  migrated_services = toset([
    "customer", "fraud", "eureka-server",
    "kafka-sms", "rabbitmq-sms", "twilio-sms"
  ])

  # Mirror of var.service_overrides to make lookups analyzer-friendly
  overrides = var.service_overrides

  # Override cpu, memory, port, or extra env vars with var.service_overrides.
  service_defaults = {
    "customer" = {
      cpu    = 512
      memory = 1024
      port   = 8080
      env_vars = [
        { name = "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE", value = "http://eureka-server:8761/eureka/" },
        { name = "SPRING_DATASOURCE_URL", value = "jdbc:postgresql://${module.stateful_infra.postgres_address}:5432/customer" },
        { name = "SPRING_KAFKA_BOOTSTRAP_SERVERS", value = module.stateful_infra.kafka_bootstrap_brokers },
        { name = "MANAGEMENT_OTLP_TRACING_ENDPOINT", value = "http://otel-collector.local:4317" },
        { name = "MANAGEMENT_OTLP_TRACING_TRANSPORT", value = "grpc" },
        { name = "SPRING_RABBITMQ_ADDRESSES", value = module.stateful_infra.rabbitmq_address },
        { name = "LOKI_URL", value = "http://loki.local" },
        { name = "JAVA_TOOL_OPTIONS", value = "-XX:MaxRAMPercentage=60.0 -XX:InitialRAMPercentage=25.0 -XX:+ExitOnOutOfMemoryError" },
        { name = "OTEL_RESOURCE_ATTRIBUTES", value = "deployment.environment=development,service.name=customer,service.version=1.0.0,host.name=$$HOSTNAME" },
        { name = "ECS_CONTAINER_METADATA_URI_V4", value = "$$ECS_CONTAINER_METADATA_URI_V4" }
      ]
      secrets = []
    }

    "eureka-server" = {
      cpu    = 512
      memory = 1024
      port   = 8761
      env_vars = [
        { name = "EUREKA_CLIENT_REGISTER_WITH_EUREKA", value = "false" },
        { name = "EUREKA_CLIENT_FETCH_REGISTRY", value = "false" },
        { name = "JAVA_TOOL_OPTIONS", value = "-XX:MaxRAMPercentage=55.0 -XX:InitialRAMPercentage=20.0 -XX:+ExitOnOutOfMemoryError" },
        { name = "ECS_CONTAINER_METADATA_URI_V4", value = "$$ECS_CONTAINER_METADATA_URI_V4" }
      ]
      secrets = []
    }

    "fraud" = {
      cpu    = 512
      memory = 1024
      port   = 8081
      env_vars = [
        { name = "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE", value = "http://eureka-server:8761/eureka/" },
        { name = "SPRING_DATASOURCE_URL", value = "jdbc:postgresql://${module.stateful_infra.postgres_address}:5432/fraud" },
        { name = "OTEL_SDK_DISABLED", value = "false" },
        { name = "OTEL_LOGS_EXPORTER", value = "none" },
        { name = "OTEL_EXPORTER_OTLP_PROTOCOL", value = "grpc" },
        { name = "OTEL_EXPORTER_OTLP_ENDPOINT", value = "http://otel-collector.local:4317" },
        { name = "JAVA_TOOL_OPTIONS", value = "-XX:MaxRAMPercentage=60.0 -XX:InitialRAMPercentage=25.0 -XX:+ExitOnOutOfMemoryError" },
        { name = "OTEL_RESOURCE_ATTRIBUTES", value = "deployment.environment=development,service.name=fraud,service.version=1.0.0,host.name=$$HOSTNAME" },
        { name = "ECS_CONTAINER_METADATA_URI_V4", value = "$$ECS_CONTAINER_METADATA_URI_V4" }
      ]
      secrets = []
    }

    "kafka-sms" = {
      cpu    = 256
      memory = 512
      port   = 8498
      env_vars = [
        { name = "SPRING_KAFKA_BOOTSTRAP_SERVERS", value = module.stateful_infra.kafka_bootstrap_brokers },
        { name = "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE", value = "http://eureka-server:8761/eureka/" },
        { name = "JAVA_TOOL_OPTIONS", value = "-XX:MaxRAMPercentage=55.0 -XX:InitialRAMPercentage=20.0 -XX:+ExitOnOutOfMemoryError" },
        { name = "ECS_CONTAINER_METADATA_URI_V4", value = "$$ECS_CONTAINER_METADATA_URI_V4" }
      ]
      secrets = []
    }

    "rabbitmq-sms" = {
      cpu    = 256
      memory = 512
      port   = 8445
      env_vars = [
        { name = "SPRING_RABBITMQ_ADDRESSES", value = module.stateful_infra.rabbitmq_address },
        { name = "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE", value = "http://eureka-server:8761/eureka/" },
        { name = "JAVA_TOOL_OPTIONS", value = "-XX:MaxRAMPercentage=55.0 -XX:InitialRAMPercentage=20.0 -XX:+ExitOnOutOfMemoryError" },
        { name = "ECS_CONTAINER_METADATA_URI_V4", value = "$$ECS_CONTAINER_METADATA_URI_V4" }
      ]
      secrets = []
    }

    "twilio-sms" = {
      cpu    = 256
      memory = 512
      port   = 8444
      env_vars = [
        { name = "SPRING_KAFKA_BOOTSTRAP_SERVERS", value = module.stateful_infra.kafka_bootstrap_brokers },
        { name = "SPRING_RABBITMQ_ADDRESSES", value = module.stateful_infra.rabbitmq_address },
        { name = "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE", value = "http://eureka-server:8761/eureka/" },
        { name = "JAVA_TOOL_OPTIONS", value = "-XX:MaxRAMPercentage=55.0 -XX:InitialRAMPercentage=20.0 -XX:+ExitOnOutOfMemoryError" },
        { name = "ECS_CONTAINER_METADATA_URI_V4", value = "$$ECS_CONTAINER_METADATA_URI_V4" }
      ]
      secrets = [
        { name = "TWILIO_ACCOUNT_SID", valueFrom = module.twilio_secrets.ecs_secret_references["TWILIO_ACCOUNT_SID"] },
        { name = "TWILIO_AUTH_TOKEN", valueFrom = module.twilio_secrets.ecs_secret_references["TWILIO_AUTH_TOKEN"] },
        { name = "TWILIO_FROM_NUMBER", valueFrom = module.twilio_secrets.ecs_secret_references["TWILIO_FROM_NUMBER"] }
      ]
    }
  }

  # Application Routing and Target Group Layouts
  exposed_services = {
    "customer"      = { port = 8080, path = "/customer/*", priority = 10, health_check_path = "/actuator/health" }
    "fraud"         = { port = 8081, path = "/fraud/*", priority = 20, health_check_path = "/actuator/health" }
    "eureka-server" = { port = 8761, path = "/eureka-server/*", priority = 30, health_check_path = "/actuator/health" }
    "twilio-sms"    = { port = 8444, path = "/twilio-sms/*", priority = 40, health_check_path = "/actuator/health" }
    "rabbitmq-sms"  = { port = 8445, path = "/rabbitmq-sms/*", priority = 50, health_check_path = "/actuator/health" }
    "kafka-sms"     = { port = 8498, path = "/kafka-sms/*", priority = 60, health_check_path = "/actuator/health" }
  }

  # Combines Lookups, Images, and Custom Variable Extractions
  services_config = {
    for service in local.migrated_services : service => {
      image_path = "${data.aws_ecr_repository.microservices[service].repository_url}:latest"

      cpu    = try(local.overrides[service].cpu, local.service_defaults[service].cpu)
      memory = try(local.overrides[service].memory, local.service_defaults[service].memory)
      port   = try(local.overrides[service].port, local.service_defaults[service].port)

      env_vars = concat(
        local.service_defaults[service].env_vars,
        try(local.overrides[service].env_vars, [])
      )
      secrets = lookup(local.service_defaults[service], "secrets", [])
    }
  }
}
