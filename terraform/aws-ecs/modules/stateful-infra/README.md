Purpose
-------
The `stateful-infra` module provisions stateful components used by the microservices: an Amazon MSK (Kafka) cluster, an Amazon MQ (RabbitMQ) broker, and a PostgreSQL RDS instance. It exposes connection endpoints used by application containers.

What it contains
- Amazon MSK cluster (Kafka) resources and related configuration
- Amazon MQ (RabbitMQ) broker
- Amazon RDS PostgreSQL instance
- Any required subnets/security group wiring is expected to be supplied by the caller

How it works
- The module takes private subnet IDs and a pre-created security group for brokers. It creates managed services (MSK, MQ, RDS) and returns their primary endpoints for consumption by application task definitions.

Important inputs
- `private_subnet_ids` - list of subnets for stateful services
- `brokers_security_group_id` - security group allowing cluster traffic
- DB and MQ credentials (sensitive variables)

Key outputs
- Kafka-related outputs: `kafka_cluster_arn`, `kafka_bootstrap_brokers`, `kafka_bootstrap_brokers_tls`, etc.
- RabbitMQ outputs: `rabbitmq_broker_id`, `rabbitmq_endpoints`, `rabbitmq_address` (convenience string).
- Postgres outputs: `postgres_instance_id`, `postgres_address`, `postgres_endpoint`, `postgres_database_name`.

Notes
- This module is intentionally opinionated and designed for development/test environments. Production-grade stateful infrastructure often needs multi-AZ RDS configurations, fine-tuned MSK settings, and additional monitoring/backup configuration.

