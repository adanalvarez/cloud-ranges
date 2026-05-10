provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}

data "aws_caller_identity" "current" {}

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

resource "random_string" "data_bucket_suffix" {
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
  customer_portal_data_bucket_name = "nrg-prod-customer-portal-data-${random_string.data_bucket_suffix.result}"
}