variable "repositories" {
  description = "Map of ECR repository names to their configuration"
  type = map(object({
    dockerhub_source_image = string                  # E.g., "library/ubuntu:latest" or "apache/kafka:latest"
    image_tag              = optional(string, "latest") # Tag applied in ECR
    scan_on_push           = optional(bool, true)
    encryption_type        = optional(string, "AES256")
    image_tag_mutability   = optional(string, "MUTABLE")
    retention_days         = optional(number, 30)
  }))

  validation {
    condition = alltrue([
      for repo in values(var.repositories) :
      repo.encryption_type == "AES256" || repo.encryption_type == "KMS"
      ])
    error_message = "encryption_type must be either 'AES256' or 'KMS'."
  }
}

variable "tags" {
  description = "Tags to apply to all repositories"
  type        = map(string)
  default     = {}
}


