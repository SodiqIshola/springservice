Security groups (short)

This module creates three security groups used by the examples:

- `public-alb-sg` — allows HTTP (80) and HTTPS (443) from the internet.
- `ecs-apps-sg` — backend application SG; ingress is allowed from the ALB SG on service ports (8080, 8081, 8761, 8498, 8445, 8444).
- `internal-brokers-sg` — internal brokers SG; allows traffic from `ecs-apps-sg` to broker ports (9092, 2181, 5672, 15672).

Primary outputs
- `alb_security_group_id`, `ecs_apps_security_group_id`, `brokers_security_group_id` (IDs and ARNs available in outputs.tf)

Keep rules tight in production: prefer explicit SG-to-SG rules (what this module uses) and avoid opening ports to `0.0.0.0/0` except for the ALB.
