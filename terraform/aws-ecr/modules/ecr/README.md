ECR Module (short)

Creates a set of ECR repositories for microservices with configurable image scanning, encryption, and lifecycle policies.

What it contains
- `aws_ecr_repository` resources for each microservice.
- Image scanning on push (configurable).
- Encryption at rest (AES256 or KMS).
- Lifecycle policies to expire old images and untagged images.

How it works
- You pass a map `repositories` keyed by service name, with optional scanning and encryption settings.
- The module creates one ECR repository per entry and attaches lifecycle policies to keep only recent images and clean up untagged artifacts.

Important inputs
- `repositories` (map): service names mapped to configuration (scan_on_push, encryption_type, retention_days).
- `name_prefix` (string): prefix applied to all repository names.

Key outputs
- `registry_url` – AWS account ID (used to construct full ECR URL).
- `repository_urls` – map of service names to full ECR repository URLs.
- `repository_arns` – map of service names to ARNs.
- `repository_names` – map of service names to actual ECR repository names created.

Notes
- Lifecycle policies keep the latest 10 images and expire untagged images after 7 days.
- Use `repository_urls` output to populate Terraform variables for ECS task definitions or CI/CD scripts.

