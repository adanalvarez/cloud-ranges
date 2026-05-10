locals {
  data_objects = {
    "exports/customers/customer_export_2026_03.csv" = {
      source       = "customer_export_2026_03.csv"
      content_type = "text/csv"
    }
    "exports/orders/orders_2026_q1.csv" = {
      source       = "orders_2026_q1.csv"
      content_type = "text/csv"
    }
    "reports/revenue/customer_lifetime_value.csv" = {
      source       = "customer_lifetime_value.csv"
      content_type = "text/csv"
    }
    "internal/access_review_notes.txt" = {
      source       = "access_review_notes.txt"
      content_type = "text/plain"
    }
    "success_marker.txt" = {
      source       = "success_marker.txt"
      content_type = "text/plain"
    }
  }
}

resource "aws_s3_bucket" "customer_portal_data" {
  bucket        = local.customer_portal_data_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "customer_portal_data" {
  bucket = aws_s3_bucket.customer_portal_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "customer_portal_data" {
  bucket = aws_s3_bucket.customer_portal_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "customer_portal_data" {
  bucket = aws_s3_bucket.customer_portal_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "customer_portal_data" {
  for_each = local.data_objects

  bucket                 = aws_s3_bucket.customer_portal_data.id
  key                    = each.key
  source                 = "${path.module}/data/${each.value.source}"
  etag                   = filemd5("${path.module}/data/${each.value.source}")
  content_type           = each.value.content_type
  server_side_encryption = "AES256"
}