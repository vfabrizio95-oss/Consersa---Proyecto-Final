resource "aws_s3_bucket" "pdfs" {
  bucket = lower("${local.prefix}-pdfs")
  tags = {
    Name = "${local.prefix}-pdfs"
  }
}

resource "aws_s3_bucket_versioning" "pdfs" {
  bucket = aws_s3_bucket.pdfs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "pdfs" {
  bucket = aws_s3_bucket.pdfs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
      kms_master_key_id = aws_kms_key.main.arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "pdfs" {
  bucket = aws_s3_bucket.pdfs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "pdfs" {
  bucket = aws_s3_bucket.pdfs.id
  rule {
    id     = "archivado"
    status = "Enabled"
    transition {
      days = 90
      storage_class = "STANDARD_IA"
    }
    transition {
      days = 365
      storage_class = "GLACIER"
    }
  }
}