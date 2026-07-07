# ==============================================================================
# CONFIGURATION BOUNDARIES
# ==============================================================================
$AWS_PROFILE    = "terraform-profile"  # Explicitly targeting your profile
$AWS_REGION     = "us-east-1"          # Update to your target AWS region

# Fetch active account ID explicitly using your targeted profile
$AWS_ACCOUNT_ID = (aws sts get-caller-identity --profile $AWS_PROFILE --query "Account" --output text)

# Map your custom Docker Hub image tags to your standardized ECR repository naming convention
$ImageMapping = @{
    "sunky24/eureka-server:latest"          = "eureka-server"
    "sunky24/kafkasms-service:latest"       = "kafka-sms"
    "sunky24/twilosms-service:latest"       = "twilio-sms"
    "sunky24/rabbitmqsms-service:latest"    = "rabbitmq-sms"
    "sunky24/fraud-service:latest"          = "fraud"
    "sunky24/customer-service:latest"       = "customer"
}

# ==============================================================================
# AUTHENTICATION PLANE
# ==============================================================================
Write-Host "Authenticating with Amazon ECR using profile '$AWS_PROFILE'..." -ForegroundColor Cyan
$EcrRegistryUrl = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# Extract the password using the profile and pipe it into the Docker daemon
aws ecr get-login-password --profile $AWS_PROFILE --region $AWS_REGION | docker login --username AWS --password-stdin $EcrRegistryUrl

if ($LASTEXITCODE -ne 0) {
    Write-Error "AWS ECR Login failed. Please verify that your '$AWS_PROFILE' profile is valid."
    exit 1
}

# ==============================================================================
# ENGINE PROCESSING LOOP
# ==============================================================================
foreach ($SourceImage in $ImageMapping.Keys) {
    $TargetRepoName = $ImageMapping[$SourceImage]
    $FullTargetEcrPath = "${EcrRegistryUrl}/${TargetRepoName}:latest"

    Write-Host "`n Processing: [$SourceImage] ---> [$FullTargetEcrPath]" -ForegroundColor Yellow

    # 1. Infrastructure Safety Check: Verify/Create the Target ECR Repository
    Write-Host "   Checking if ECR repository '$TargetRepoName' exists..." -ForegroundColor Gray
    aws ecr describe-repositories --repository-names $TargetRepoName --profile $AWS_PROFILE --region $AWS_REGION 2>$null

    if ($LASTEXITCODE -ne 0) {
        Write-Host "   Repository missing. Creating ECR Repository: $TargetRepoName..." -ForegroundColor Magenta
        aws ecr create-repository --repository-name $TargetRepoName --profile $AWS_PROFILE --region $AWS_REGION --image-scanning-configuration scanOnPush=true --encryption-configuration encryptionType=AES256 >$null
    }

    # 2. Network Sync: Pull from Docker Hub
    Write-Host "  Pulling from Docker Hub..." -ForegroundColor Blue
    docker pull $SourceImage
    if ($LASTEXITCODE -ne 0) { Write-Error "Failed to pull $SourceImage"; continue }

    # 3. Retagging Plane
    Write-Host " Tagging for AWS ECR..." -ForegroundColor Blue
    docker tag $SourceImage $FullTargetEcrPath

    # 4. Network Sync: Push to ECR
    Write-Host "  Pushing to AWS ECR..." -ForegroundColor Green
    docker push $FullTargetEcrPath
    if ($LASTEXITCODE -ne 0) { Write-Error "Failed to push $FullTargetEcrPath"; continue }

    # 5. Local Cleanup: Free up disk space on your local runner machine
    Write-Host " Cleaning up local cache images..." -ForegroundColor Gray
    docker rmi $SourceImage $FullTargetEcrPath >$null 2>&1
}

Write-Host "`n Migration successfully complete! All images are safe in ECR." -ForegroundColor Green
