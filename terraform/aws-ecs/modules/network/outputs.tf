# =============================================================================
# Terraform Network Module Outputs
# =============================================================================

# VPC Information
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the created VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "ARN of the created VPC"
  value       = aws_vpc.main.arn
}

# Subnet Information
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of the public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of the private subnets"
  value       = aws_subnet.private[*].cidr_block
}

# Availability Zones
output "availability_zones" {
  description = "Availability zones used for the subnets"
  value       = data.aws_availability_zones.available.names
}

# Gateway Information
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

# Route Table Information
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = aws_route_table.private[*].id
}

# VPC Endpoints
output "s3_endpoint_id" {
  description = "ID of the S3 VPC endpoint (if enabled)"
  value       = var.enable_s3_endpoint ? aws_vpc_endpoint.s3[0].id : null
}

output "dynamodb_endpoint_id" {
  description = "ID of the DynamoDB VPC endpoint (if enabled)"
  value       = var.enable_dynamodb_endpoint ? aws_vpc_endpoint.dynamodb[0].id : null
}

output "ecr_api_endpoint_id" {
  description = "ID of the ECR API VPC endpoint (if enabled)"
  value       = var.enable_ecr_endpoints ? aws_vpc_endpoint.ecr_api[0].id : null
}

output "ecr_dkr_endpoint_id" {
  description = "ID of the ECR DKR VPC endpoint (if enabled)"
  value       = var.enable_ecr_endpoints ? aws_vpc_endpoint.ecr_dkr[0].id : null
}

output "logs_endpoint_id" {
  description = "ID of the CloudWatch Logs VPC endpoint (if enabled)"
  value       = var.enable_logs_endpoint ? aws_vpc_endpoint.logs[0].id : null
}

# Network Configuration Summary
output "network_config" {
  description = "Summary of the network configuration"
  value = {
    vpc_id             = aws_vpc.main.id
    vpc_cidr           = aws_vpc.main.cidr_block
    availability_zones = data.aws_availability_zones.available.names
    public_subnets     = length(aws_subnet.public)
    private_subnets    = length(aws_subnet.private)
    nat_gateways       = length(aws_nat_gateway.main)
    internet_gateway   = aws_internet_gateway.main.id != "" ? true : false
  }
}
