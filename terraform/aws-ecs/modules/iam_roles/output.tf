# ==========================================================================
# ECS TASK EXECUTION ROLE OUTPUTS (Infrastructure & Setup)
# ==========================================================================

output "execution_role_arn" {
  description = "The Amazon Resource Name (ARN) of the ECS Task Execution Role. Use this in your ecs_task_definition under 'execution_role_arn'."
  value       = aws_iam_role.ecs_execution_role.arn
}

output "execution_role_name" {
  description = "The name of the ECS Task Execution Role."
  value       = aws_iam_role.ecs_execution_role.name
}

output "execution_role_id" {
  description = "The stable, unique ID assigned by AWS to the ECS Task Execution Role."
  value       = aws_iam_role.ecs_execution_role.id
}

# ==========================================================================
# ECS TASK ROLE OUTPUTS (Application-Level Permissions)
# ==========================================================================

output "task_role_arn" {
  description = "The Amazon Resource Name (ARN) of the ECS Task Role. Use this in your ecs_task_definition under 'task_role_arn'."
  value       = aws_iam_role.ecs_task_role.arn
}

output "task_role_name" {
  description = "The name of the ECS Task Role."
  value       = aws_iam_role.ecs_task_role.name
}

output "task_role_id" {
  description = "The stable, unique ID assigned by AWS to the ECS Task Role."
  value       = aws_iam_role.ecs_task_role.id
}

# ==========================================================================
# CUSTOM APPLICATION POLICY OUTPUTS
# ==========================================================================

output "custom_app_policy_arn" {
  description = "The ARN of the custom application permissions policy attached to the Task Role."
  value       = aws_iam_policy.app_permissions.arn
}

