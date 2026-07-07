ECR Dev Environment

This environment provisions ECR repositories for all SpringService microservices.

How to run
1. Initialize (first time):
   terraform init

2. Plan to see what will be created:
   terraform plan

3. Apply to create repositories:
   terraform apply

After apply, you can extract outputs:
   terraform output -json > ecr-output.json

Outputs
- `registry_url` – Full ECR registry URL (e.g., 123456789.dkr.ecr.us-east-1.amazonaws.com)
- `repository_urls` – Map of service names to full ECR URLs (ready for Docker pushes)
- `repository_names` – Map of service names to ECR repository names

Use these outputs in:
- PowerShell sync scripts (populate the $EcrRegistryUrl variable)
- Terraform ECS module (populate image paths)
- CI/CD pipelines (for image tagging and pushing)

Example: Extract registry URL for PowerShell
   $EcrRegistryUrl = terraform output -raw registry_url

Example: Get a specific repository URL
   terraform output -json repository_urls | jq .customer

Repositories created
- springservice-customer
- springservice-fraud
- springservice-eureka-server
- springservice-kafka-sms
- springservice-rabbitmq-sms
- springservice-twilio-sms

All repositories have:
- Image scanning on push (vulnerability detection)
- Encryption at rest (AES256)
- Lifecycle policies (keep latest 10 images, expire untagged after 7 days)

