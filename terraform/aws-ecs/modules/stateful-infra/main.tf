# ==========================================================================
# CLOUDWATCH LOG GROUPS
# ==========================================================================
resource "aws_cloudwatch_log_group" "kafka" {
  name              = "/aws/vendedlogs/msk/${var.name_prefix}-kafka" # Pattern required by AWS for MSK logging
  retention_in_days = 14
  tags              = var.tags
}


# ==========================================================================
# AMAZON MSK (MANAGED STREAMING FOR KAFKA - KRAFT MODE)
# ==========================================================================
# Fully managed Kafka. No Zookeeper required (handled natively via KRaft).
resource "aws_msk_cluster" "kafka" {
  cluster_name           = "${var.name_prefix}-kafka"
  kafka_version          = "3.6.0" # Stable Kafka version supporting KRaft
  number_of_broker_nodes = length(var.private_subnet_ids)

  broker_node_group_info {
    instance_type   = var.kafka_instance_type
    client_subnets  = var.private_subnet_ids
    security_groups = [var.brokers_security_group_id]

    storage_info {
      ebs_storage_info {
        volume_size = var.kafka_broker_volume_size
      }
    }
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "TLS_PLAINTEXT" # Allows PLAINTEXT internally; change to TLS for strict production compliance
      in_cluster    = true
    }
  }

  tags = var.tags
}

# ==========================================================================
# AMAZON MQ (MANAGED RABBITMQ ENGINE)
# ==========================================================================
# Fully managed RabbitMQ broker instance.
resource "aws_mq_broker" "rabbitmq" {
  broker_name        = "${var.name_prefix}-rabbitmq"
  engine_type        = "RabbitMQ"
  engine_version     = "3.13" # Modern, standard stable engine version
  host_instance_type = var.rmq_instance_type

  deployment_mode = var.rmq_deployment_mode

  publicly_accessible = false
  security_groups     = [var.brokers_security_group_id]
  subnet_ids          = var.rmq_deployment_mode == "SINGLE_INSTANCE" ? [var.private_subnet_ids[0]] : var.private_subnet_ids

  user {
    username = var.rmq_username
    password = var.rmq_password
  }

  # --- ENHANCED LOGGING BLOCK ---
  # Generates broker activity, connection state logs, and system channels to CloudWatch.
  logs {
    general = true
  }

  tags = var.tags
}


# Note: Amazon MQ creates its own CloudWatch Log groups automatically when enabled.
# To adjust the retention on Amazon MQ logs, you must use a separate aws_cloudwatch_log_group_retention resource.
resource "aws_cloudwatch_log_group" "rabbitmq_log_retention" {
  # Amazon MQ automatically adopts this naming syntax natively
  name              = "/aws/amazonmq/broker/${var.name_prefix}-rabbitmq/general"
  retention_in_days = 14
  depends_on        = [aws_mq_broker.rabbitmq]
}





# ==========================================================================
# AMAZON RDS (MANAGED POSTGRESQL ENGINE)
# ==========================================================================
resource "aws_db_subnet_group" "postgres" {
  name       = "${var.name_prefix}-postgres-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags       = var.tags
}

resource "aws_db_instance" "postgres" {
  identifier            = "${var.name_prefix}-postgres"
  engine                = "postgres"
  engine_version        = "14.15"
  instance_class        = var.postgres_instance_class
  allocated_storage     = var.postgres_allocated_storage
  max_allocated_storage = var.postgres_max_allocated_storage

  db_name  = var.postgres_db_name
  username = var.postgres_username
  password = var.postgres_password

  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [var.brokers_security_group_id]
  skip_final_snapshot    = true

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  tags                            = var.tags
}



# This creates your second database automatically
resource "postgresql_database" "second_db" {
  name              = var.fraud_db_name
  encoding          = "UTF8"
  lc_collate        = "en_US.UTF8"
  lc_ctype          = "en_US.UTF8"
  connection_limit  = -1
}

