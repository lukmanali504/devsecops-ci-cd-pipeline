provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "secure_bucket" {
  bucket = "enterprise-devsecops-secure-demo-bucket"

  tags = {
    Name        = "SecureBucket"
    Environment = "Production"
  }
}

# =========================================================
# VERSIONING ENABLED
# =========================================================

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.secure_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# =========================================================
# SERVER SIDE ENCRYPTION
# =========================================================

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# =========================================================
# BLOCK PUBLIC ACCESS
# =========================================================

resource "aws_s3_bucket_public_access_block" "secure_access" {
  bucket = aws_s3_bucket.secure_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# =========================================================
# LIFECYCLE MANAGEMENT
# =========================================================

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    id     = "log"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}
