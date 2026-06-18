Purpose
-------
Provides standard IAM roles and a minimal permissions policy required for ECS task execution and runtime tasks.

What this module creates
- An ECS task execution role with the AWS managed policies needed to pull images and write logs.
- An application task role used by containers at runtime with a small custom policy (kept minimal by default).

How to use
- Reference the module outputs when creating ECS task definitions. The key outputs you will need are `execution_role_arn` and `task_role_arn`.

Important inputs
- `name` / `name_prefix` - base name used for role naming

Key outputs
- `execution_role_arn`, `execution_role_name`, `execution_role_id`
- `task_role_arn`, `task_role_name`, `task_role_id`
- `custom_app_policy_arn` - ARN of the small policy attached to the task role

Notes
- The module focuses on a pragmatic default. If your workload needs extra permissions (S3, Secrets Manager, KMS, etc.) add them to the returned task role or extend the module.

