This module provisions an ECS cluster and the per-application task definitions and services.

What it contains
- An `aws_ecs_cluster` configured with container insights enabled.
- `aws_cloudwatch_log_group` resources (one per application) used by the task definitions.
- `aws_ecs_task_definition` resources created dynamically from the `app_configurations` map.
- `aws_ecs_service` resources (one per application) that run the Fargate tasks and optionally attach to ALB target groups.

How it works (short)
- You pass a map called `app_configurations` keyed by application name. Each value must include an image path, cpu, memory, port and an array of environment variables.
- The module iterates that map and creates task definitions + services for each entry. Log groups are created per app and attached via the awslogs driver.
- If the same application name appears in the `target_group_arns` map the service will register with that ALB target group.

Important inputs (high level)
- `app_configurations` (map(object)): image_path, cpu, memory, port, env_vars
- `private_subnet_ids` (list): subnets to run Fargate tasks in
- `ecs_apps_security_group_id` (string): SG applied to tasks
- `execution_role_arn`, `task_role_arn` (string): IAM roles used by task definitions

Key outputs
- `cluster_id`, `cluster_arn` – ECS cluster identifiers
- `service_names` – map of application => ECS service name
- `task_definition_arns` – map of application => task definition ARN
- `log_group_names` – map of application => CloudWatch log group name

Notes
- This module keeps the task/service model intentionally simple for development. If you need advanced deployment options (auto-scaling, sidecars, multiple containers per task) the task definition generation is the place to extend.

