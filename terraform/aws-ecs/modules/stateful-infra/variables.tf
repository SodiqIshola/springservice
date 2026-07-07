variable "name_prefix" {
  type        = string
  description = "Base naming prefix for stateful resources"
}


variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnets for MSK and Amazon MQ (minimum 2 or 3 for Multi-AZ)"
}

variable "brokers_security_group_id" {
  type        = string
  description = "The ID of the internal-brokers-sg security group"
}

variable "fraud_db_name" {
  type        = string
  description = "The ID of the internal-brokers-sg security group"
}



variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}


variable "kafka_instance_type" {
  type        = string
  description = "MSK broker instance type"
  default     = "kafka.t3.small"
}

variable "kafka_broker_volume_size" {
  type        = number
  description = "EBS volume size in GiB for each MSK broker"
  default     = 50
}

# RabbitMQ Configurations
variable "rmq_instance_type" {
  type        = string
  description = "Amazon MQ RabbitMQ instance type"
  default     = "mq.t3.micro"
}

variable "rmq_deployment_mode" {
  type        = string
  description = "Amazon MQ RabbitMQ deployment mode"
  default     = "SINGLE_INSTANCE"

  validation {
    condition     = contains(["SINGLE_INSTANCE", "ACTIVE_STANDBY_MULTI_AZ", "CLUSTER_MULTI_AZ"], var.rmq_deployment_mode)
    error_message = "rmq_deployment_mode must be SINGLE_INSTANCE, ACTIVE_STANDBY_MULTI_AZ, or CLUSTER_MULTI_AZ."
  }
}

variable "rmq_username" {
  type        = string
  description = "RabbitMQ broker username"
  sensitive   = true
}

variable "rmq_password" {
  type        = string
  description = "RabbitMQ broker password"
  sensitive   = true
}


variable "postgres_instance_class" {
  type        = string
  description = "RDS PostgreSQL instance class"
  default     = "db.t3.medium"
}

variable "postgres_allocated_storage" {
  type        = number
  description = "Initial RDS PostgreSQL storage in GiB"
  default     = 20
}

variable "postgres_max_allocated_storage" {
  type        = number
  description = "Maximum RDS PostgreSQL autoscaled storage in GiB"
  default     = 100
}

variable "postgres_db_name" {
  type        = string
  description = "Default PostgreSQL database name"
  default     = "postgres"
}

variable "postgres_username" {
  type        = string
  description = "PostgreSQL master username"
  sensitive   = true
}

variable "postgres_password" {
  type        = string
  description = "PostgreSQL master password"
  sensitive   = true
}
