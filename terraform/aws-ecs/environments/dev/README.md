# Dev Environment

Composes the SpringService AWS development stack from the reusable modules.

## What It Deploys

- VPC with public/private subnets and optional VPC endpoints.
- Security groups for the ALB, ECS apps, and internal brokers.
- Public ALB with target groups for `customer`, `fraud`, `eureka-server`, `twilio-sms`, `rabbitmq-sms`, and `kafka-sms`.
- RDS PostgreSQL, Amazon MSK, and Amazon MQ for RabbitMQ.
- ECS Fargate services for the six SpringService containers.
- IAM roles for ECS task execution and app runtime permissions.
- Secrets Manager secrets for Twilio SMS credentials and platform credentials.

## Required Inputs

```hcl
rmq_username      = "..."
rmq_password      = "..."
postgres_username = "..."
postgres_password = "..."
twilio_account_sid = "..."
twilio_auth_token  = "..."
twilio_from_number = "..."
```

The Twilio values are injected into `twilio-sms` as ECS secrets, not plaintext environment variables. PostgreSQL and RabbitMQ credentials are stored in the platform secret and also passed to the managed services that require them.

Use `service_overrides` to adjust CPU, memory, port, or add environment variables for a specific service without editing module code.

## Run

```bash
terraform init
terraform plan
terraform apply
```
