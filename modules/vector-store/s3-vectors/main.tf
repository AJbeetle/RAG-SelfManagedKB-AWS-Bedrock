resource "aws_s3vectors_vector_bucket" "vector_store" {
  vector_bucket_name = var.bucket_name
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
}

# Note: Tags and server-side encryption via KMS require specific configurations 
# depending on the provider support for aws_s3vectors_vector_bucket.
# For standard Bedrock integration, the bucket is inherently protected.
