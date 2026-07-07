variable "name_prefix" {
  type        = string
  description = "Base naming prefix for all ECS resources"
}

variable "vpc_id" {
  type        = string
  description = "The target VPC ID"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnets where the Fargate tasks will run"
}

variable "ecs_apps_security_group_id" {
  type        = string
  description = "The ID of the ecs-apps-sg security group"
}

variable "execution_role_arn" {
  type        = string
  description = "The IAM Execution Role ARN"
}

variable "task_role_arn" {
  type        = string
  description = "The IAM Task Role ARN"
}

variable "aws_region" {
  type        = string
  description = "AWS region for CloudWatch logging"
  default     = "us-east-1"
}

# --- THE HOOK FOR DYNAMIC CONFIGURATIONS ---
variable "app_configurations" {
  type = map(object({
    image_path = string
    cpu        = number
    memory     = number
    port       = number
    env_vars = list(object({
      name  = string
      value = string
    }))
    secrets = optional(list(object({
      name      = string
      valueFrom = string
    })), [])
  }))
  description = "A mapping configuration block that cleanly defines custom execution bounds and unique properties per application."
}

variable "target_group_arns" {
  type        = map(string)
  description = "Optional ALB target group ARNs keyed by application name"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}
