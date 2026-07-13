terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.54.0, < 7.0.0"
    }
  }
}

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

      dynamic "supplemental_data_storage_configuration" {
        for_each = var.enable_multimodal ? [var.multimodal_bucket_uri] : []
        content {
          storage_location {
            type = "S3"
            s3_location {
              uri = supplemental_data_storage_configuration.value
            }
          }
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

    dynamic "s3_vectors_configuration" {
      for_each = var.storage_configuration_type == "S3_VECTORS" ? [var.storage_configuration_block.s3_vectors_configuration] : []
      content {
        index_arn = s3_vectors_configuration.value.index_arn
      }
    }
  }

  lifecycle {
    precondition {
      condition     = !(var.embedding_data_type == "BINARY" && strcontains(var.embedding_model_arn, "amazon.titan-embed-text-v1"))
      error_message = "BINARY embedding data type is not supported by Titan Embed V1. Use FLOAT32 or a compatible model."
    }

    precondition {
      condition     = !var.enable_multimodal || var.multimodal_bucket_uri != null
      error_message = "multimodal_bucket_uri must be provided when enable_multimodal is true."
    }

    precondition {
      condition = (
        var.storage_configuration_type == "OPENSEARCH_SERVERLESS"
        ? var.storage_configuration_block.opensearch_serverless_configuration != null
        : var.storage_configuration_block.s3_vectors_configuration != null
      )
      error_message = "storage_configuration_block must contain the configuration selected by storage_configuration_type."
    }
  }

  tags = var.tags
}
