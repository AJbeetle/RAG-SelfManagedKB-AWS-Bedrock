output "storage_configuration_type" {
  value       = "S3_VECTORS"
  description = "The vector store type"
}

output "storage_configuration_block" {
  value = {
    s3_vectors_configuration = {
      index_arn = aws_s3vectors_index.vector_index.index_arn
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

output "vector_index_arn" {
  value       = aws_s3vectors_index.vector_index.index_arn
  description = "ARN of the S3 Vectors index used by Bedrock"
}

output "vector_store_id" {
  value       = aws_s3vectors_index.vector_index.index_arn
  description = "Stable identifier for the S3 Vectors backend"
}
