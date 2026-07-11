output "storage_configuration_type" {
  value       = "S3_VECTORS"
  description = "The vector store type"
}

output "storage_configuration_block" {
  value = {
    s3_vectors_configuration = {
      bucket_arn        = aws_s3vectors_vector_bucket.vector_store.vector_bucket_arn
      vector_index_name = var.vector_index_name
      dimensions        = var.vector_dimensions
      distance_metric   = var.distance_metric
      field_mapping = {
        vector_field   = "vector"
        text_field     = var.text_field_name
        metadata_field = var.metadata_field_name
      }
    }
  }
  description = "The storage configuration block for Bedrock Knowledge Base"
}

output "vector_bucket_name" {
  value = aws_s3vectors_vector_bucket.vector_store.vector_bucket_name
}

output "vector_store_arn" {
  value = aws_s3vectors_vector_bucket.vector_store.vector_bucket_arn
}
