Public ALB module (short)

Creates an internet-facing Application Load Balancer and its listeners/target groups for the example services.

Primary inputs
- `vpc_id`, `subnets` (public subnet ids), `alb_security_group_id` (or let the module create one), `exposed_services` map.

Primary outputs
- `alb_arn`, `alb_dns_name`, `alb_security_group_id`, `target_group_arns` (map)

See `terraform/examples/basic` for a minimal wiring example.
