output "terraform_state_bucket_name" {
  description = "S3 bucket that will store the prod Terraform remote state."
  value       = aws_s3_bucket.terraform_state.bucket
}

output "logs_bucket_name" {
  description = "S3 bucket reserved for platform logging destinations."
  value       = aws_s3_bucket.platform_logs.bucket
}

output "region" {
  description = "Region used for both bootstrap and prod deployments."
  value       = var.region
}

output "state_object_key" {
  description = "Stable S3 object key that the prod backend uses for state."
  value       = var.state_object_key
}

output "backend_init_example" {
  description = "Example command for initializing the prod backend with the created state bucket."
  value       = "terraform init -backend-config=\"bucket=${aws_s3_bucket.terraform_state.bucket}\" -backend-config=\"key=${var.state_object_key}\" -backend-config=\"region=${var.region}\" -backend-config=\"encrypt=true\""
}