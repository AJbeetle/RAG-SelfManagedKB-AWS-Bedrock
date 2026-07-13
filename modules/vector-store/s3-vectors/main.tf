terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.54.0, < 7.0.0"
    }
  }
}

resource "aws_s3vectors_vector_bucket" "vector_store" {
  vector_bucket_name = var.bucket_name
  encryption_configuration = var.kms_key_arn == null ? null : [{
    kms_key_arn = var.kms_key_arn
    sse_type    = "aws:kms"
  }]
  tags = var.tags
}

resource "aws_s3vectors_index" "vector_index" {
  index_name         = var.vector_index_name
  vector_bucket_name = aws_s3vectors_vector_bucket.vector_store.vector_bucket_name

  dimension       = var.vector_dimensions
  data_type       = "float32"
  distance_metric = var.distance_metric

  metadata_configuration {
    non_filterable_metadata_keys = [var.text_field_name, var.metadata_field_name]
  }

  tags = var.tags
}
