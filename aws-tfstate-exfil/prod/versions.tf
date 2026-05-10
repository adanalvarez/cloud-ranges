terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    key     = "env/customer-portal/prod/terraform.tfstate"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.42.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
  }
}