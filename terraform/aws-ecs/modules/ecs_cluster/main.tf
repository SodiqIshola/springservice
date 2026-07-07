# ==========================================================================
# ECS CORE COMPUTING CLUSTER
# ==========================================================================
resource "aws_ecs_cluster" "main" {
  name = "${var.name_prefix}-core-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled" # Enables CloudWatch tracking dashboards automatically
  }

  tags = var.tags
}


################################################################################
# AWS Cloud Map HTTP Namespace Configuration
# Used for ECS Service Connect microservices communication within the mesh
################################################################################
resource "aws_service_discovery_http_namespace" "this" {
  name        = "${var.name_prefix}-mesh"
  description = "Cloud Map namespace for ECS Service Connect microservices"
  tags        = var.tags
}



# ==========================================================================
# MONITORED SERVICE CLOUDWATCH LOG GROUPS
# ==========================================================================
resource "aws_cloudwatch_log_group" "apps" {
  for_each          = var.app_configurations
  name              = "/ecs/${var.name_prefix}/${each.key}"
  retention_in_days = 14
  tags              = var.tags
}

# ==========================================================================
# DYNAMIC TASK DEFINITIONS
# ==========================================================================
resource "aws_ecs_task_definition" "apps" {
  for_each                 = var.app_configurations
  family                   = "${var.name_prefix}-${each.key}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = each.key
      essential = true
      image     = each.value.image_path
      portMappings = [
        {
          name          = "${each.key}-port"
          containerPort = each.value.port
          hostPort      = each.value.port
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]

      # Seamlessly loads the dedicated variable array map provided per app
      environment = each.value.env_vars
      secrets     = each.value.secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.apps[each.key].name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = each.key
        }
      }
    }
  ])
}

# ==========================================================================
# DYNAMIC ECS WORKLOAD SERVICES
# ==========================================================================
resource "aws_ecs_service" "apps" {
  for_each        = var.app_configurations
  name            = "${var.name_prefix}-${each.key}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.apps[each.key].arn
  desired_count   = 1
  launch_type     = "FARGATE"

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_apps_security_group_id]
    assign_public_ip = false
  }

  # Attaches an Application Load Balancer target group if the service name matches a key in var.target_group_arns
  dynamic "load_balancer" {
    for_each = contains(keys(var.target_group_arns), each.key) ? [var.target_group_arns[each.key]] : []

    content {
      target_group_arn = load_balancer.value
      container_name   = each.key
      container_port   = each.value.port
    }
  }

  # Configures Service Connect for internal service-to-service communication mesh
  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.this.arn

    service {
      discovery_name = each.key
      port_name      = "${each.key}-port"

      client_alias {
        dns_name = each.key
        port     = each.value.port
      }
    }
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}



