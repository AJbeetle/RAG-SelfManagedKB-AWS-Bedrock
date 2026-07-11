module "ingestion_config" {
  source = "../../ingestion-config"

  chunking_strategy                        = var.chunking_strategy
  fixed_size_max_tokens                    = var.fixed_size_max_tokens
  fixed_size_overlap_percentage            = var.fixed_size_overlap_percentage
  hierarchical_parent_max_tokens           = var.hierarchical_parent_max_tokens
  hierarchical_child_max_tokens            = var.hierarchical_child_max_tokens
  hierarchical_overlap_tokens              = var.hierarchical_overlap_tokens
  semantic_max_tokens                      = var.semantic_max_tokens
  semantic_breakpoint_percentile_threshold = var.semantic_breakpoint_percentile_threshold
  
  parsing_strategy                         = var.parsing_strategy
  parsing_model_arn                        = var.parsing_model_arn
  parsing_prompt                           = var.parsing_prompt
  
  transformation_lambda_arn                = var.transformation_lambda_arn
}

resource "aws_bedrockagent_data_source" "this" {
  knowledge_base_id    = var.knowledge_base_id
  name                 = var.data_source_name
  description          = var.data_source_description
  data_deletion_policy = var.deletion_policy

  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn         = var.s3_bucket_arn
      inclusion_prefixes = length(var.s3_inclusion_prefixes) > 0 ? var.s3_inclusion_prefixes : null
    }
  }

  dynamic "vector_ingestion_configuration" {
    for_each = module.ingestion_config.vector_ingestion_configuration != null ? [module.ingestion_config.vector_ingestion_configuration] : []
    content {
      dynamic "chunking_configuration" {
        for_each = vector_ingestion_configuration.value.chunking_configuration != null ? [vector_ingestion_configuration.value.chunking_configuration] : []
        content {
          chunking_strategy = chunking_configuration.value.chunking_strategy
          
          dynamic "fixed_size_chunking_configuration" {
            for_each = chunking_configuration.value.fixed_size_chunking_configuration != null ? [chunking_configuration.value.fixed_size_chunking_configuration] : []
            content {
              max_tokens         = fixed_size_chunking_configuration.value.max_tokens
              overlap_percentage = fixed_size_chunking_configuration.value.overlap_percentage
            }
          }
          
          dynamic "hierarchical_chunking_configuration" {
            for_each = chunking_configuration.value.hierarchical_chunking_configuration != null ? [chunking_configuration.value.hierarchical_chunking_configuration] : []
            content {
              overlap_tokens = hierarchical_chunking_configuration.value.overlap_tokens
              dynamic "level_configuration" {
                for_each = hierarchical_chunking_configuration.value.level_configuration
                content {
                  max_tokens = level_configuration.value.max_tokens
                }
              }
            }
          }
          
          dynamic "semantic_chunking_configuration" {
            for_each = chunking_configuration.value.semantic_chunking_configuration != null ? [chunking_configuration.value.semantic_chunking_configuration] : []
            content {
              max_token                      = semantic_chunking_configuration.value.max_token
              breakpoint_percentile_threshold = semantic_chunking_configuration.value.breakpoint_percentile_threshold
              buffer_size                    = semantic_chunking_configuration.value.buffer_size
            }
          }
        }
      }
      
      dynamic "parsing_configuration" {
        for_each = vector_ingestion_configuration.value.parsing_configuration != null ? [vector_ingestion_configuration.value.parsing_configuration] : []
        content {
          parsing_strategy = parsing_configuration.value.parsing_strategy
          dynamic "bedrock_foundation_model_configuration" {
            for_each = parsing_configuration.value.bedrock_foundation_model_configuration != null ? [parsing_configuration.value.bedrock_foundation_model_configuration] : []
            content {
              model_arn = bedrock_foundation_model_configuration.value.model_arn
              dynamic "parsing_prompt" {
                for_each = bedrock_foundation_model_configuration.value.parsing_prompt != null ? [bedrock_foundation_model_configuration.value.parsing_prompt] : []
                content {
                  parsing_prompt_string = parsing_prompt.value.parsing_prompt_string
                }
              }
            }
          }
        }
      }
      
      dynamic "custom_transformation_configuration" {
        for_each = vector_ingestion_configuration.value.custom_transformation_configuration != null ? [vector_ingestion_configuration.value.custom_transformation_configuration] : []
        content {
          dynamic "intermediate_storage" {
            for_each = custom_transformation_configuration.value.intermediate_storage != null ? [custom_transformation_configuration.value.intermediate_storage] : []
            content {
              dynamic "s3_location" {
                for_each = intermediate_storage.value.s3_location != null ? [intermediate_storage.value.s3_location] : []
                content {
                  uri = s3_location.value.uri
                }
              }
            }
          }
          dynamic "transformation" {
            for_each = custom_transformation_configuration.value.transformation != null ? custom_transformation_configuration.value.transformation : []
            content {
              step_to_apply = transformation.value.step_to_apply
              dynamic "transformation_function" {
                for_each = transformation.value.transformation_function != null ? [transformation.value.transformation_function] : []
                content {
                  dynamic "transformation_lambda_configuration" {
                    for_each = transformation_function.value.transformation_lambda_configuration != null ? [transformation_function.value.transformation_lambda_configuration] : []
                    content {
                      lambda_arn = transformation_lambda_configuration.value.lambda_arn
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
