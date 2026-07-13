mock_provider "aws" {}

run "renders_s3_vectors_storage" {
  command = plan

  variables {
    kb_name              = "test-kb"
    role_arn             = "arn:aws:iam::123456789012:role/test-kb-role"
    embedding_model_arn  = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"
    embedding_dimensions = 1024

    storage_configuration_type = "S3_VECTORS"
    storage_configuration_block = {
      s3_vectors_configuration = {
        index_arn = "arn:aws:s3vectors:us-east-1:123456789012:bucket/test-bucket/index/test-index"
      }
    }
  }

  assert {
    condition     = aws_bedrockagent_knowledge_base.this.storage_configuration[0].s3_vectors_configuration[0].index_arn == "arn:aws:s3vectors:us-east-1:123456789012:bucket/test-bucket/index/test-index"
    error_message = "The S3 Vectors index ARN was not rendered into the knowledge base storage configuration."
  }
}

run "renders_multimodal_storage" {
  command = plan

  variables {
    kb_name              = "test-kb"
    role_arn             = "arn:aws:iam::123456789012:role/test-kb-role"
    embedding_model_arn  = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"
    embedding_dimensions = 1024

    storage_configuration_type = "OPENSEARCH_SERVERLESS"
    storage_configuration_block = {
      opensearch_serverless_configuration = {
        collection_arn    = "arn:aws:aoss:us-east-1:123456789012:collection/test"
        vector_index_name = "test-index"
        field_mapping = {
          vector_field   = "embedding"
          text_field     = "text"
          metadata_field = "metadata"
        }
      }
    }

    enable_multimodal     = true
    multimodal_bucket_uri = "s3://test-multimodal-bucket"
  }

  assert {
    condition     = aws_bedrockagent_knowledge_base.this.knowledge_base_configuration[0].vector_knowledge_base_configuration[0].supplemental_data_storage_configuration[0].storage_location[0].s3_location[0].uri == "s3://test-multimodal-bucket"
    error_message = "The multimodal S3 URI was not rendered into supplemental data storage."
  }
}
