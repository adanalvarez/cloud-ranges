output "terraform_state_bucket_name" {
  description = "S3 bucket that stores the prod Terraform remote state."
  value       = var.terraform_state_bucket_name
}

output "fake_protected_customer_data_bucket_name" {
  description = "S3 bucket containing the fictional customer portal exports and success marker."
  value       = aws_s3_bucket.customer_portal_data.bucket
}

output "logs_bucket_name" {
  description = "S3 bucket reserved for platform logs."
  value       = var.logs_bucket_name
}

output "starting_iam_username" {
  description = "Initial low-privilege IAM user for the scenario."
  value       = aws_iam_user.platform_terraform_state_reader.name
}

output "starting_iam_access_key_id" {
  description = "Access key ID for the starting IAM user."
  value       = aws_iam_access_key.platform_terraform_state_reader.id
  sensitive   = true
}

output "starting_iam_secret_access_key" {
  description = "Secret access key for the starting IAM user."
  value       = aws_iam_access_key.platform_terraform_state_reader.secret
  sensitive   = true
}

output "expected_role_arn" {
  description = "Role ARN that the leaked CI identity can assume."
  value       = aws_iam_role.customer_portal_readonly.arn
}

output "state_object_key" {
  description = "S3 object key for the prod Terraform state file."
  value       = var.state_object_key
}

output "state_exposure_warning" {
  description = "Operator warning for the intentionally exposed sandbox-only credential path."
  value       = "This sandbox intentionally stores the svc-prod-ci-deploy access key in Terraform state. Treat the remote state object as sensitive and deploy only in a dedicated sandbox AWS account."
}