provider "aws" {
  region = "ap-south-1"
}

# =========================================================
# KMS KEY
# =========================================================

resource "aws_kms_key" "s3_kms" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 7

  enable_key_rotation = true
}

# =========================================================
# MAIN SECURE BUCKET
# =========================================================

resource "aws_s3_bucket" "secure_bucket" {
  bucket = "enterprise-devsecops-secure-demo-bucket"

  tags = {
    Name        = "SecureBucket"
    Environment = "Production"
  }
}

# =========================================================
# LOGGING BUCKET
# =========================================================

resource "aws_s3_bucket" "log_bucket" {
  bucket = "enterprise-devsecops-log-demo-bucket"

  tags = {
    Name = "LogBucket"
  }
}

# =========================================================
# VERSIONING - MAIN BUCKET
# =========================================================

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.secure_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# =========================================================
# VERSIONING - LOG BUCKET
# =========================================================

resource "aws_s3_bucket_versioning" "log_bucket_versioning" {
  bucket = aws_s3_bucket.log_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# =========================================================
# KMS ENCRYPTION - MAIN BUCKET
# =========================================================

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_kms.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# =========================================================
# KMS ENCRYPTION - LOG BUCKET
# =========================================================

resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket_encryption" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_kms.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# =========================================================
# PUBLIC ACCESS BLOCK - MAIN BUCKET
# =========================================================

resource "aws_s3_bucket_public_access_block" "secure_access" {
  bucket = aws_s3_bucket.secure_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# =========================================================
# PUBLIC ACCESS BLOCK - LOG BUCKET
# =========================================================

resource "aws_s3_bucket_public_access_block" "log_secure_access" {
  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# =========================================================
# ACCESS LOGGING
# =========================================================

resource "aws_s3_bucket_logging" "logging" {
  bucket = aws_s3_bucket.secure_bucket.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
}

# =========================================================
# LIFECYCLE - MAIN BUCKET
# =========================================================

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    id     = "main-lifecycle"
    status = "Enabled"

    expiration {
      days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# =========================================================
# LIFECYCLE - LOG BUCKET
# =========================================================

resource "aws_s3_bucket_lifecycle_configuration" "log_lifecycle" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    id     = "log-lifecycle"
    status = "Enabled"

    expiration {
      days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
