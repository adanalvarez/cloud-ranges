variable "region" {
  description = "AWS region for this dedicated sandbox deployment. Default: eu-west-1."
  type        = string
  default     = "eu-west-1"
}

variable "confirm_sandbox_environment" {
  description = "Must be set to true before apply. Deploy only into a dedicated AWS sandbox account that contains no production data or credentials."
  type        = bool
  default     = false
}

variable "terraform_state_bucket_name" {
  description = "Bootstrap output: the S3 bucket name used for the prod Terraform backend state."
  type        = string
}

variable "logs_bucket_name" {
  description = "Bootstrap output: the S3 bucket name reserved for platform logs."
  type        = string
}

variable "state_object_key" {
  description = "Stable S3 object key used by the prod Terraform backend."
  type        = string
  default     = "env/customer-portal/prod/terraform.tfstate"
}