locals {
  state_object_arn = "arn:aws:s3:::${var.terraform_state_bucket_name}/${var.state_object_key}"
  state_bucket_arn = "arn:aws:s3:::${var.terraform_state_bucket_name}"
  data_bucket_arn  = aws_s3_bucket.customer_portal_data.arn
}

resource "aws_iam_user" "platform_terraform_state_reader" {
  name = "platform-terraform-state-reader"
}

resource "aws_iam_access_key" "platform_terraform_state_reader" {
  user = aws_iam_user.platform_terraform_state_reader.name
}

resource "aws_iam_user" "svc_prod_ci_deploy" {
  name = "svc-prod-ci-deploy"
}

# This access key is intentionally created through Terraform so it is persisted in
# the remote state object. That mirrors the misconfiguration path the sandbox is
# meant to test, while remaining contained to the sandbox account.
resource "aws_iam_access_key" "svc_prod_ci_deploy" {
  user = aws_iam_user.svc_prod_ci_deploy.name
}

resource "aws_iam_role" "customer_portal_readonly" {
  name = "customer-portal-readonly-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          AWS = aws_iam_user.svc_prod_ci_deploy.arn
        }
      }
    ]
  })
}

resource "aws_iam_user_policy" "platform_terraform_state_reader" {
  name = "platform-terraform-state-reader-policy"
  user = aws_iam_user.platform_terraform_state_reader.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowCallerIdentity"
        Effect   = "Allow"
        Action   = "sts:GetCallerIdentity"
        Resource = "*"
      },
      {
        Sid    = "AllowSelfPolicyEnumeration"
        Effect = "Allow"
        Action = [
          "iam:ListUserPolicies",
          "iam:GetUserPolicy",
          "iam:ListAttachedUserPolicies"
        ]
        Resource = aws_iam_user.platform_terraform_state_reader.arn
      },
      {
        Sid      = "AllowListStateBucketPrefix"
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = local.state_bucket_arn
        Condition = {
          StringEquals = {
            "s3:prefix" = var.state_object_key
          }
        }
      },
      {
        Sid      = "AllowReadSpecificStateObject"
        Effect   = "Allow"
        Action   = "s3:GetObject"
        Resource = local.state_object_arn
      }
    ]
  })
}

resource "aws_iam_user_policy" "svc_prod_ci_deploy" {
  name = "svc-prod-ci-deploy-policy"
  user = aws_iam_user.svc_prod_ci_deploy.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowCallerIdentity"
        Effect   = "Allow"
        Action   = "sts:GetCallerIdentity"
        Resource = "*"
      },
      {
        Sid      = "AllowAssumeReadonlyRole"
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = aws_iam_role.customer_portal_readonly.arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "customer_portal_readonly" {
  name = "customer-portal-readonly-policy"
  role = aws_iam_role.customer_portal_readonly.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowCallerIdentity"
        Effect   = "Allow"
        Action   = "sts:GetCallerIdentity"
        Resource = "*"
      },
      {
        Sid      = "AllowListDataBucket"
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = local.data_bucket_arn
      },
      {
        Sid      = "AllowReadDataObjects"
        Effect   = "Allow"
        Action   = "s3:GetObject"
        Resource = "${local.data_bucket_arn}/*"
      }
    ]
  })
}