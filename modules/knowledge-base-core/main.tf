resource "aws_bedrockagent_knowledge_base" "this" {
  name     = var.kb_name
  role_arn = var.role_arn
  
  description = var.kb_description

  knowledge_base_configuration {
    type = "VECTOR"
    vector_knowledge_base_configuration {
      embedding_model_arn = var.embedding_model_arn
      
      # Optional block, supported for modern models
      embedding_model_configuration {
        bedrock_embedding_model_configuration {
          dimensions          = var.embedding_dimensions
          embedding_data_type = var.embedding_data_type
        }
      }
    }
  }

  storage_configuration {
    type = var.storage_configuration_type

    dynamic "opensearch_serverless_configuration" {
      for_each = var.storage_configuration_type == "OPENSEARCH_SERVERLESS" ? [var.storage_configuration_block.opensearch_serverless_configuration] : []
      content {
        collection_arn    = opensearch_serverless_configuration.value.collection_arn
        vector_index_name = opensearch_serverless_configuration.value.vector_index_name
        field_mapping {
          vector_field   = opensearch_serverless_configuration.value.field_mapping.vector_field
          text_field     = opensearch_serverless_configuration.value.field_mapping.text_field
          metadata_field = opensearch_serverless_configuration.value.field_mapping.metadata_field
        }
      }
    }

    # In actual AWS provider, S3_VECTORS might not be a valid storage type directly on KB.
    # We include it generically based on the contract if supported, or error if not.
    # Note: If S3 is not natively supported as a storage config block, 
    # the provider will reject it at plan time.
  }
  
  tags = var.tags
}
