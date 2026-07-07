


locals {
  inbound_ports = {
    "http"  = 80
    "https" = 443
  }
}

locals {
  microservices_ports = {
    "customer"      = 8080
    "fraud"         = 8081
    "eureka-server" = 8761
    "kafka-sms"     = 8498
    "rabbitmq-sms"  = 8445
    "twilio-sms"    = 8444
  }
}

locals {
  aws_managed_brokers = {
    "rabbitmq"       = 5672
    "rabbitmq-ui"    = 15672
    "external-kafka" = 29092
    "kafka"          = 9092
    "postgres"       = 5432 # Add database access port
    "pgadmin"        = 5050 # Add management dashboard port
  }
}

# ==========================================================================
# PUBLIC APPLICATION LOAD BALANCER SECURITY GROUP
# ==========================================================================
# Role: Public entrypoint. Allows public web traffic on ports 80 and 443.
# ==========================================================================
resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-public-alb-sg"
  description = "Public entrypoint for internet traffic"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name_prefix}-public-alb-sg" })

  egress {
    from_port   = 0
    to_port     = 0
    description = "Allow outbound routing directly to backend app tasks"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Required to route traffic to your private subnets
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_inbound" {
  for_each          = local.inbound_ports
  security_group_id = aws_security_group.alb.id
  description       = "Allow public internet traffic for ${each.key}"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = each.value
  to_port           = each.value
  ip_protocol       = "tcp"
}


# ==========================================================================
# ECS MICROSERVICES SECURITY GROUP
# ==========================================================================
# Role: Hosts core applications. Accepts traffic routed only from the ALB.
# ==========================================================================
resource "aws_security_group" "ecs_apps" {
  name        = "${var.name_prefix}-ecs-apps-sg"
  description = "Security group for ECS microservices backend tasks"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name_prefix}-ecs-apps-sg" })

  egress {
    from_port   = 0
    to_port     = 0
    description = "Allow outbound traffic for external API calls and package downloads"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Ingress: ALB to ECS (Strict SG-to-SG)
resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
  for_each          = local.microservices_ports
  security_group_id = aws_security_group.ecs_apps.id
  description       = "Allow traffic from ALB to microservice ${each.key}"

  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = each.value
  to_port                      = each.value
  ip_protocol                  = "tcp"
}

# Intra-Cluster Ingress (Allows microservices to talk to each other)
resource "aws_vpc_security_group_ingress_rule" "ecs_internal_communication" {
  for_each          = local.microservices_ports
  security_group_id = aws_security_group.ecs_apps.id
  description       = "Allow microservices to communicate with ${each.key} internally"

  referenced_security_group_id = aws_security_group.ecs_apps.id # Self-referencing rule
  from_port                    = each.value
  to_port                      = each.value
  ip_protocol                  = "tcp"
}

# ==========================================================================
# INTERNAL BROKERS SECURITY GROUP
# ==========================================================================
# Role: Event streaming & queues. Accepts traffic routed from ECS apps.
# ==========================================================================

resource "aws_security_group" "brokers" {
  name        = "${var.name_prefix}-internal-brokers-sg"
  description = "Security group for internal message brokers and databases"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name_prefix}-internal-brokers-sg" })

  # IMPROVEMENT: Hardened Egress. Databases/Brokers don't need out-of-vpc internet routing.
  egress {
    from_port   = 0
    to_port     = 0
    description = "Isolate stateful data layers; restrict outbound internet access"
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block] # Restricts outbound traffic purely to your local VPC network
  }
}

# Ingress: ECS Apps to Stateful Brokers (Strict SG-to-SG)
resource "aws_vpc_security_group_ingress_rule" "brokers_from_ecs" {
  for_each          = local.aws_managed_brokers
  security_group_id = aws_security_group.brokers.id
  description       = "Allow traffic from ECS applications to broker ${each.key}"

  referenced_security_group_id = aws_security_group.ecs_apps.id
  from_port                    = each.value
  to_port                      = each.value
  ip_protocol                  = "tcp"
}









