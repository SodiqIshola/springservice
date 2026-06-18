variable "name_prefix" {
  type        = string
  description = "Base name for the ALB and associated resources"
}


variable "vpc_id" {
  type        = string
  description = "The target VPC ID where the ALB and Target Groups will be deployed"
}


variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs to deploy the internet-facing ALB"
}


variable "alb_security_group_id" {
  type        = string
  description = "The security group ID from the public-alb-sg resource"
}


variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources"
  default     = {}
}

variable "exposed_services" {
  description = "Services exposed by the public ALB, keyed by service name"
  type = map(object({
    port              = number
    path              = string
    priority          = number
    health_check_path = optional(string, "/actuator/health")
  }))
  default = {}
}
