
variable "name_prefix" {
  description = "Base naming prefix for Secrets Manager resources"
  type        = string
}

variable "name" {
  description = "Logical secret name suffix"
  type        = string
}

variable "secret_values" {
  description = "Secret key/value pairs stored as one JSON secret"
  type        = map(string)
  sensitive   = true
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
