provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "public_bucket" {
  bucket = "enterprise-devsecops-public-demo-lukmanali-bucket"

  tags = {
    Name = "PublicBucket"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.public_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.public_bucket.id
  acl    = "public-read"
}
