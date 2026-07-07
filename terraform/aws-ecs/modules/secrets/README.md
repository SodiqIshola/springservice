# Secrets Module

Creates one AWS Secrets Manager secret that stores key/value pairs as JSON.

## What It Creates

- `aws_secretsmanager_secret`
- `aws_secretsmanager_secret_version`

## Inputs

| Name | Description |
| --- | --- |
| `name_prefix` | Prefix for the secret name. |
| `name` | Secret name suffix. The final name is `<name_prefix>/<name>`. |
| `secret_values` | Sensitive map stored as JSON in Secrets Manager. |
| `tags` | Optional tags for the secret. |

## Outputs

| Name | Description |
| --- | --- |
| `secret_arn` | Secret ARN. |
| `secret_name` | Secret name. |
| `ecs_secret_references` | ECS `valueFrom` references for each JSON key. |
| `secret_values` | Sensitive map for Terraform-managed resources that require direct values. |

## Example

```hcl
module "twilio_secrets" {
  source      = "../../modules/secrets"
  name_prefix = "springservice"
  name        = "twilio-sms"

  secret_values = {
    TWILIO_ACCOUNT_SID = var.twilio_account_sid
    TWILIO_AUTH_TOKEN  = var.twilio_auth_token
    TWILIO_FROM_NUMBER = var.twilio_from_number
  }
}
```

Use `ecs_secret_references` when a container needs a secret:

```hcl
{
  name      = "TWILIO_AUTH_TOKEN"
  valueFrom = module.twilio_secrets.ecs_secret_references["TWILIO_AUTH_TOKEN"]
}
```

Do not output secret values. Only output secret names, ARNs, or ECS references.

Use `secret_values` only when an AWS resource argument requires the literal value at plan/apply time, such as RDS or Amazon MQ usernames and passwords. These values are sensitive, but Terraform will still track them in state because the managed resources require them.
