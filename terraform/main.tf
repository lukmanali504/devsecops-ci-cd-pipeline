provider "aws" {
  region = "ap-south-1"
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
# ENABLE ACCESS LOGGING
# =========================================================

resource "aws_s3_bucket_logging" "logging" {
  bucket = aws_s3_bucket.secure_bucket.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
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
# KMS ENCRYPTION
# =========================================================

resource "aws_kms_key" "s3_kms" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 7
}

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

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# =========================================================
# CROSS REGION REPLICATION PLACEHOLDER
# =========================================================

resource "aws_s3_bucket_replication_configuration" "replication" {
  depends_on = [aws_s3_bucket_versioning.versioning]

  role   = "arn:aws:iam::123456789012:role/s3-replication-role"
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    id     = "ReplicationRule"
    status = "Enabled"

    destination {
      bucket        = "arn:aws:s3:::enterprise-devsecops-backup-bucket"
      storage_class = "STANDARD"
    }
  }
}
