# SpringService Terraform

Terraform infrastructure for running the SpringService microservices on AWS ECS Fargate.

## Layout

```text
terraform/
  environments/dev/        # Development composition
  modules/network/         # VPC, subnets, NAT, optional VPC endpoints
  modules/security_group/  # ALB, ECS app, and broker security groups
  modules/public_alb/      # Public ALB, listener, listener rules, target groups
  modules/secrets/         # JSON secrets in AWS Secrets Manager
  modules/stateful-infra/  # MSK Kafka, Amazon MQ RabbitMQ, RDS PostgreSQL
  modules/iam_roles/       # ECS task execution and app task roles
  modules/ecs_cluster/     # ECS cluster, services, task definitions, log groups
```

## Dev Environment

The dev environment deploys these application containers from ECR:

| Service | Port | Docker Compose equivalent |
| --- | ---: | --- |
| `customer` | `8080` | `sunky24/customer-service:latest` |
| `fraud` | `8081` | `sunky24/fraud-service:latest` |
| `eureka-server` | `8761` | `sunky24/eureka-server:latest` |
| `twilio-sms` | `8444` | `sunky24/twilosms-service:latest` |
| `rabbitmq-sms` | `8445` | `sunky24/rabbitmqsms-service:latest` |
| `kafka-sms` | `8498` | `sunky24/kafkasms-service:latest` |

The environment also creates managed equivalents for local Docker dependencies:

| Local container | AWS resource |
| --- | --- |
| `postgres` | RDS PostgreSQL |
| `kafka` | Amazon MSK |
| `rabbitmq` | Amazon MQ for RabbitMQ |

Observability containers from Docker Compose (`grafana`, `prometheus`, `loki`, `tempo`, `promtail`, `otel-collector`, `node-exporter`, `cadvisor`) are not created by this Terraform stack.

## ALB Routes

The dev environment creates target groups and listener rules for:

| Service | Path |
| --- | --- |
| `customer` | `/customer/*` |
| `fraud` | `/fraud/*` |
| `eureka-server` | `/eureka-server/*` |
| `twilio-sms` | `/twilio-sms/*` |
| `rabbitmq-sms` | `/rabbitmq-sms/*` |
| `kafka-sms` | `/kafka-sms/*` |

Each ECS service with a matching target group is attached automatically.

## Required Parameters

Pass sensitive values with a `terraform.tfvars` file, environment variables, or your CI secret store:

```hcl
rmq_username      = "..."
rmq_password      = "..."
postgres_username = "..."
postgres_password = "..."
twilio_account_sid = "..."
twilio_auth_token  = "..."
twilio_from_number = "..."
```

The Twilio values are stored in one Secrets Manager JSON secret and injected into the `twilio-sms` ECS container as `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, and `TWILIO_FROM_NUMBER`. PostgreSQL and RabbitMQ credentials are stored in a separate platform secret.

Optional per-service overrides:

```hcl
service_overrides = {
  "customer" = {
    cpu    = 1024
    memory = 2048
    env_vars = [
      { name = "EXAMPLE_FLAG", value = "true" }
    ]
  }
}
```

## Commands

Run from `terraform/environments/dev`:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Useful outputs include the VPC IDs, ALB DNS name, ECS service names, log groups, target group ARNs, PostgreSQL endpoint, Kafka brokers, RabbitMQ endpoints, and secret ARNs/names.
