locals {
  vector_ingestion_configuration = {
    chunking_configuration = var.chunking_strategy != "NONE" ? {
      chunking_strategy = var.chunking_strategy

      fixed_size_chunking_configuration = var.chunking_strategy == "FIXED_SIZE" ? {
        max_tokens         = var.fixed_size_max_tokens
        overlap_percentage = var.fixed_size_overlap_percentage
      } : null

      hierarchical_chunking_configuration = var.chunking_strategy == "HIERARCHICAL" ? {
        level_configuration = [
          {
            max_tokens = var.hierarchical_parent_max_tokens
          },
          {
            max_tokens = var.hierarchical_child_max_tokens
          }
        ]
        overlap_tokens = var.hierarchical_overlap_tokens
      } : null

      semantic_chunking_configuration = var.chunking_strategy == "SEMANTIC" ? {
        max_token                      = var.semantic_max_tokens
        breakpoint_percentile_threshold = var.semantic_breakpoint_percentile_threshold
        buffer_size                    = var.semantic_buffer_size
      } : null
    } : null

    parsing_configuration = var.parsing_strategy != "NONE" ? {
      parsing_strategy = var.parsing_strategy

      bedrock_foundation_model_configuration = var.parsing_strategy == "BEDROCK_FOUNDATION_MODEL" ? {
        model_arn = var.parsing_model_arn
        parsing_prompt = var.parsing_prompt != null ? {
          parsing_prompt_string = var.parsing_prompt
        } : null
      } : null
    } : null

    custom_transformation_configuration = var.transformation_lambda_arn != null ? {
      intermediate_storage = {
        s3_location = {
          uri = "s3://placeholder-handled-by-data-source" 
        }
      }
      transformation = [
        {
          transformation_function = {
            transformation_lambda_configuration = {
              lambda_arn = var.transformation_lambda_arn
            }
          }
          step_to_apply = "POST_CHUNKING"
        }
      ]
    } : null
  }
}
