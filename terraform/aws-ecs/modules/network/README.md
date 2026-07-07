# Network module (short)

Creates a VPC with 2 AZs, two public subnets and two private subnets. Includes NAT gateways, route tables and optional VPC endpoints (S3, ECR, CloudWatch Logs, DynamoDB).

Inputs (high level)
- `name_prefix`, `vpc_cidr`, `aws_region`
- Booleans to enable endpoint resources

Important outputs
- `vpc_id`, `public_subnet_ids`, `private_subnet_ids`, `availability_zones`

Use the examples in `terraform/examples` for full usage.

<parameter name="filePath">C:\Java-App\springservice\terraform\modules\network\README.md
