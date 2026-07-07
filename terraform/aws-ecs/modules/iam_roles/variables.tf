variable "name" {
  type        = string
  description = "Base naming prefix for IAM resources"
}

variable "msk_cluster_arn" {
  type        = string
  description = "The ARN of the Amazon MSK Kafka cluster to grant connection rights"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}

variable "secrets_manager_secret_arns" {
  type        = list(string)
  description = "Secrets Manager secret ARNs the ECS execution role can read for container secret injection"
  default     = []
}

