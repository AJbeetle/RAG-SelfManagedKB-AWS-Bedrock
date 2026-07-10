resource "aws_s3_bucket" "vector_store" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "vector_store" {
  bucket = aws_s3_bucket.vector_store.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = var.kms_key_arn != null ? "aws:kms" : "AES256"
    }
  }
}

# Note: "Vector index resource" on S3 is conceptual here, as there isn't a native AWS provider resource
# for "S3 vector index" unless using a specific integration. We output the configuration required.
