# ==========================================================================
# ECR REPOSITORIES
# ==========================================================================
resource "aws_ecr_repository" "repos" {
  for_each = var.repositories

  name = each.key

  # Enable image scanning on push for vulnerability detection
  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }

  # Encryption for data at rest
  encryption_configuration {
    encryption_type = each.value.encryption_type
  }

  # Allows Terraform to destroy the repo even if it contains images
  force_delete         = true

  image_tag_mutability = each.value.image_tag_mutability

  tags = merge(var.tags, {
    Name = each.key
  })
}

# ==========================================================================
# ECR LIFECYCLE POLICIES - RETENTION & CLEANUP
# ==========================================================================
resource "aws_ecr_lifecycle_policy" "repos" {
  for_each = var.repositories

  repository = aws_ecr_repository.repos[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep the latest 10 images; expire older images after ${each.value.retention_days} days"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}


# ==========================================================================
# DOCKER HUB TO ECR IMAGE SYNC PIPELINE
# ==========================================================================
# STEP 1: Pull the source image from Docker Hub (Kept exactly as you had it)
resource "docker_image" "pull" {
  for_each = var.repositories
  name     = each.value.dockerhub_source_image
}

# STEP 2: Tag the image locally (CHANGING THIS TO THE DOCKER_TAG RESOURCE)
resource "docker_tag" "ecr_alias" {
  for_each = var.repositories

  # The exact ID of the local image you pulled in Step 1
  source_image = docker_image.pull[each.key].image_id

  # The target URL destination and tag for your AWS ECR Repository
  target_image = "${aws_ecr_repository.repos[each.key].repository_url}:${each.value.image_tag}"
}

# STEP 3: Push the tagged image into AWS ECR
resource "docker_registry_image" "sync" {
  for_each = var.repositories

  # References the target image string calculated in Step 2
  name = docker_tag.ecr_alias[each.key].target_image

  # Tracks the source image digest so upgrades trigger a clean update push
  triggers = {
    image_id = docker_image.pull[each.key].repo_digest
  }

  keep_remotely = true
}
