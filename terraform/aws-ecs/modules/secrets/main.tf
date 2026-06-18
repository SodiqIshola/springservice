# ==========================================================================
# AWS SECRETS MANAGER MODULE
# ==========================================================================
# Secured KMS Key with explicit IAM ownership policy
resource "aws_kms_key" "secrets" {
  description             = "KMS Key for microservice environment secrets"
  deletion_window_in_days = 30 # Safer compliance window
  enable_key_rotation     = true
  tags                    = var.tags

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
}

# Data source required to dynamically fetch the active AWS Account ID for the policy above
data "aws_caller_identity" "current" {}

# Hardened Secrets Manager container
resource "aws_secretsmanager_secret" "app_secrets" {
  name                    = "${var.name_prefix}/${var.name}"
  recovery_window_in_days = 7
  kms_key_id              = aws_kms_key.secrets.arn

  tags = merge(var.tags, {
    Name = "${var.name_prefix}/${var.name}"
  })
}

# Dynamic JSON Key-Value payload generation using placeholders for high-risk inputs
resource "aws_secretsmanager_secret_version" "app_secrets_val" {
  secret_id     = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode(var.secret_values)

  # Prevents Terraform from overwriting the passwords after they are manually updated in AWS
  lifecycle {
    ignore_changes = [secret_string]
  }
}


