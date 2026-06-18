# ==========================================================================
# TRUST POLICY DATA SOURCE (Shared by both roles)
# ==========================================================================
data "aws_iam_policy_document" "ecs_tasks_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ==========================================================================
# ECS TASK EXECUTION ROLE (Infrastructure / Image Pulling / Setup)
# ==========================================================================
resource "aws_iam_role" "ecs_execution_role" {
  name               = "${var.name}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_trust.json
  tags               = var.tags
}

# Standard policy allows the Service Connect sidecar agent to pull its proxy image
resource "aws_iam_role_policy_attachment" "ecs_execution_standard" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_execution_secrets" {
  count = length(var.secrets_manager_secret_arns) > 0 ? 1 : 0

  statement {
    effect    = "Allow"
    resources = var.secrets_manager_secret_arns
    actions   = ["secretsmanager:GetSecretValue"]
  }
}

resource "aws_iam_policy" "ecs_execution_secrets" {
  count       = length(var.secrets_manager_secret_arns) > 0 ? 1 : 0
  name        = "${var.name}-ecs-execution-secrets-policy"
  description = "Allows ECS to inject Secrets Manager values into containers"
  policy      = data.aws_iam_policy_document.ecs_execution_secrets[0].json
}

resource "aws_iam_role_policy_attachment" "ecs_execution_secrets" {
  count      = length(var.secrets_manager_secret_arns) > 0 ? 1 : 0
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_execution_secrets[0].arn
}

# ==========================================================================
# ECS TASK ROLE (Application-Level & Service Connect Runtime Permissions)
# ==========================================================================
resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.name}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_trust.json
  tags               = var.tags
}

# CloudWatch metrics policy
resource "aws_iam_role_policy_attachment" "ecs_task_cw_metrics" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# OpenTelemetry tracing policy
resource "aws_iam_role_policy_attachment" "otel_xray_write" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

# App-Level Policy Document
data "aws_iam_policy_document" "app_permissions" {
  # Logging permissions
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
  }

  # Service Connect telemetry and discovery runtime permissions
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "ecs:DiscoverPollEndpoint",
      "ecs:SubmitTaskStateChange",
      "ecs:SubmitContainerStateChange",
      "ecs:GetTaskProtection",
      "ecs:UpdateTaskProtection",
      "aws-market:RegisterUsage"
    ]
  }

  # MSK Kafka access rules
  statement {
    effect = "Allow"
    resources = [
      var.msk_cluster_arn,
      "${replace(var.msk_cluster_arn, "cluster", "topic")}/*",
      "${replace(var.msk_cluster_arn, "cluster", "group")}/*"
    ]
    actions = [
      "kafka-cluster:Connect",
      "kafka-cluster:AlterCluster",
      "kafka-cluster:DescribeCluster",
      "kafka-cluster:WriteData",
      "kafka-cluster:ReadData",
      "kafka-cluster:DescribeTopic",
      "kafka-cluster:AlterTopic",
      "kafka-cluster:CreateTopic",
      "kafka-cluster:DescribeGroup",
      "kafka-cluster:AlterGroup"
    ]
  }

  # Amazon MQ rules
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "mq:DescribeBroker",
      "mq:ListBrokers"
    ]
  }
}

resource "aws_iam_policy" "app_permissions" {
  name        = "${var.name}-app-permissions-policy"
  description = "Permissions policy for runtime data layers, logging, and Service Connect telemetry"
  policy      = data.aws_iam_policy_document.app_permissions.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_custom" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.app_permissions.arn
}
