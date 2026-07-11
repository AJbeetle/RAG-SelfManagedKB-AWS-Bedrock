resource "aws_s3_bucket" "multimodal" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "multimodal_encryption" {
  bucket = aws_s3_bucket.multimodal.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = var.kms_key_arn != null ? "aws:kms" : "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "multimodal_versioning" {
  bucket = aws_s3_bucket.multimodal.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}
