output "storage_configuration_type" {
  value       = "OPENSEARCH_SERVERLESS"
  description = "The vector store type"
}

output "storage_configuration_block" {
  value = {
    opensearch_serverless_configuration = {
      collection_arn    = aws_opensearchserverless_collection.this.arn
      vector_index_name = var.vector_index_name
      field_mapping = {
        vector_field   = var.vector_field_name
        text_field     = var.text_field_name
        metadata_field = var.metadata_field_name
      }
    }
  }
  description = "The storage configuration block for Bedrock Knowledge Base"
}

output "vector_store_id" {
  value       = aws_opensearchserverless_collection.this.id
  description = "The OpenSearch Serverless collection ID"
}
