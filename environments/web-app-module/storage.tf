# Seperating the s3 provisioning to a different file

resource "aws_s3_bucket" "web_app_bucket" {
  bucket        = var.bucket_prefix
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "web_app_bucket" {
  bucket = aws_s3_bucket.web_app_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "web_app_bucket" {
  bucket = aws_s3_bucket.web_app_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
