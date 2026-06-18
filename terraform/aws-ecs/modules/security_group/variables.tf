variable "name_prefix" {
  type        = string
  description = "Base name for the ALB and associated resources"
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the security group"
  type        = map(string)
  default     = {}
}


variable "vpc_cidr_block" {
  type        = string
  description = "VPC ID where the security group will be created"
}
