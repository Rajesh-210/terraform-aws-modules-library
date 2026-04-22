##############################################################
# MODULE: S3
# Creates an S3 bucket with versioning, encryption,
# lifecycle rules, and optional static website hosting.
##############################################################

resource "aws_s3_bucket" "main" {
  bucket        = "${var.project_name}-${var.environment}-${var.bucket_suffix}"
  force_destroy = var.force_destroy
  tags          = merge(var.tags, { Name = "${var.project_name}-${var.environment}-${var.bucket_suffix}" })
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count  = var.enable_lifecycle ? 1 : 0
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_days
    }

    expiration {
      days = var.object_expiry_days
    }
  }
}

output "bucket_id"   { value = aws_s3_bucket.main.id }
output "bucket_arn"  { value = aws_s3_bucket.main.arn }
output "bucket_name" { value = aws_s3_bucket.main.bucket }
