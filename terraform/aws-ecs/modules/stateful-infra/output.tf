# ==========================================================================
# AMAZON MSK (KAFKA) OUTPUTS
# ==========================================================================
output "kafka_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the MSK Cluster."
  value       = aws_msk_cluster.kafka.arn
}

output "kafka_bootstrap_brokers" {
  description = "Comma-separated list of connection strings for Kafka brokers (PLAINTEXT)."
  value       = aws_msk_cluster.kafka.bootstrap_brokers
}

output "kafka_bootstrap_brokers_sasl_iam" {
  description = "Comma-separated list of connection strings for IAM authenticated Kafka brokers."
  value       = aws_msk_cluster.kafka.bootstrap_brokers_sasl_iam
}

output "kafka_bootstrap_brokers_tls" {
  description = "Comma-separated list of connection strings for TLS-encrypted Kafka brokers."
  value       = aws_msk_cluster.kafka.bootstrap_brokers_tls
}


# ==========================================================================
# AMAZON MQ (RABBITMQ) OUTPUTS
# ==========================================================================
output "rabbitmq_broker_id" {
  description = "The unique identifier of the RabbitMQ broker instance."
  value       = aws_mq_broker.rabbitmq.id
}

output "rabbitmq_broker_arn" {
  description = "The Amazon Resource Name (ARN) of the RabbitMQ broker instance."
  value       = aws_mq_broker.rabbitmq.arn
}

output "rabbitmq_endpoints" {
  description = "The URL endpoints to connect to the RabbitMQ instance web console or API protocols."
  value       = aws_mq_broker.rabbitmq.instances[*].endpoints
}

output "rabbitmq_address" {
  description = "The primary AMQP endpoint string generated for application integration."
  value       = try(split("//", aws_mq_broker.rabbitmq.instances[0].endpoints[0])[1], "")
}


# ==========================================================================
# AMAZON RDS (POSTGRESQL) OUTPUTS
# ==========================================================================
output "postgres_instance_id" {
  description = "The RDS instance identifier."
  value       = aws_db_instance.postgres.identifier
}

output "postgres_address" {
  description = "The connection endpoint address for the PostgreSQL database instance."
  value       = aws_db_instance.postgres.address
}

output "postgres_endpoint" {
  description = "The complete host address and port connection string combined (host:port)."
  value       = aws_db_instance.postgres.endpoint
}

output "postgres_database_name" {
  description = "The default bootstrap database name."
  value       = aws_db_instance.postgres.db_name
}
