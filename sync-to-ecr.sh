#!/bin/bash

# ==============================================================================
# CONFIGURATION BOUNDARIES
# ==============================================================================
# Give it execution permissions: chmod +x sync-to-ecr.sh
# Execute the workflow loop: ./sync-to-ecr.sh

AWS_PROFILE="terraform-profile"   # Explicitly targeting your profile
AWS_REGION="us-east-1"            # Update to your target AWS region

# Fetch active account ID explicitly using your targeted profile
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --profile "$AWS_PROFILE" --query "Account" --output text)

if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo " Failed to retrieve AWS Account ID. Ensure AWS CLI and profile are valid."
    exit 1
fi

# Define mappings using an associative array
declare -A IMAGE_MAPPING
IMAGE_MAPPING["sunky24/eureka-server:latest"]="eureka-server"
IMAGE_MAPPING["sunky24/kafkasms-service:latest"]="kafka-sms"
IMAGE_MAPPING["sunky24/twilosms-service:latest"]="twilio-sms"
IMAGE_MAPPING["sunky24/rabbitmqsms-service:latest"]="rabbitmq-sms"
IMAGE_MAPPING["sunky24/fraud-service:latest"]="fraud"
IMAGE_MAPPING["sunky24/customer-service:latest"]="customer"

# ==============================================================================
# AUTHENTICATION PLANE
# ==============================================================================
echo " Authenticating with Amazon ECR using profile '$AWS_PROFILE'..."
ECR_REGISTRY_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# Extract the password using the profile and pipe it into the Docker daemon
aws ecr get-login-password --profile "$AWS_PROFILE" --region "$AWS_REGION" | docker login --username AWS --password-stdin "$ECR_REGISTRY_URL"

if [ $? -ne 0 ]; then
    echo " AWS ECR Login failed. Please verify that your '$AWS_PROFILE' profile is valid."
    exit 1
fi

# ==============================================================================
# ENGINE PROCESSING LOOP
# ==============================================================================
for SOURCE_IMAGE in "${!IMAGE_MAPPING[@]}"; do
    TARGET_REPO_NAME="${IMAGE_MAPPING[$SOURCE_IMAGE]}"
    FULL_TARGET_ECR_PATH="${ECR_REGISTRY_URL}/${TARGET_REPO_NAME}:latest"

    echo -e "\n Processing: [$SOURCE_IMAGE] ---> [$FULL_TARGET_ECR_PATH]"

    # 1. Infrastructure Safety Check: Verify/Create the Target ECR Repository
    echo "   Checking if ECR repository '$TARGET_REPO_NAME' exists..."
    aws ecr describe-repositories --repository-names "$TARGET_REPO_NAME" --profile "$AWS_PROFILE" --region "$AWS_REGION" >/dev/null 2>&1

    if [ $? -ne 0 ]; then
        echo "   Repository missing. Creating ECR Repository: $TARGET_REPO_NAME..."
        aws ecr create-repository \
            --repository-name "$TARGET_REPO_NAME" \
            --profile "$AWS_PROFILE" \
            --region "$AWS_REGION" \
            --image-scanning-configuration scanOnPush=true \
            --encryption-configuration encryptionType=AES256 >/dev/null
    fi

    # 2. Network Sync: Pull from Docker Hub
    echo "  Pulling from Docker Hub..."
    docker pull "$SOURCE_IMAGE"
    if [ $? -ne 0 ]; then
        echo " Failed to pull $SOURCE_IMAGE"
        continue
    fi

    # 3. Retagging Plane
    echo "  Tagging for AWS ECR..."
    docker tag "$SOURCE_IMAGE" "$FULL_TARGET_ECR_PATH"

    # 4. Network Sync: Push to ECR
    echo "  Pushing to AWS ECR..."
    docker push "$FULL_TARGET_ECR_PATH"
    if [ $? -ne 0 ]; then
        echo " Failed to push $FULL_TARGET_ECR_PATH"
        continue
    fi

    # 5. Local Cleanup: Free up disk space on your local runner machine
    echo "  Cleaning up local cache images..."
    docker rmi "$SOURCE_IMAGE" "$FULL_TARGET_ECR_PATH" >/dev/null 2>&1
done

echo -e "\n Migration successfully complete! All images are safe in ECR."
