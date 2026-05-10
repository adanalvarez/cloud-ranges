provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}

locals {
  common_tags = {
    Company     = "Northstar Retail Group"
    Environment = "prod"
    Application = "customer-portal"
    CostCenter  = "retail-platform"
    Owner       = "platform-engineering"
    ManagedBy   = "terraform"
  }
}

resource "random_string" "bucket_suffix" {
  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false

  lifecycle {
    precondition {
      condition     = var.confirm_sandbox_environment
      error_message = "Set confirm_sandbox_environment=true and deploy only into a dedicated AWS sandbox account."
    }
  }
}

locals {
  terraform_state_bucket_name = "nrg-prod-tfstate-${random_string.bucket_suffix.result}"
  logs_bucket_name            = "nrg-prod-platform-logs-${random_string.bucket_suffix.result}"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket        = local.terraform_state_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "platform_logs" {
  bucket        = local.logs_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "platform_logs" {
  bucket = aws_s3_bucket.platform_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "platform_logs" {
  bucket = aws_s3_bucket.platform_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "platform_logs" {
  bucket = aws_s3_bucket.platform_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}