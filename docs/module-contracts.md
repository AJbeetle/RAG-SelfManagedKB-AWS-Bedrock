# Module Contracts

This document outlines the inputs, outputs, and dependencies for each module in the repository.

## `iam-runtime-role`
### Inputs
- `create_role` (bool, default: true)
- `existing_role_arn` (string, default: "")
- `role_name` (string)
- `s3_data_bucket_arns` (list(string), default: [])
- `enable_secrets_manager` (bool, default: false)
- `enable_kms_policy` (bool, default: false)
- `kms_key_arns` (list(string), default: [])
- `transformation_lambda_arns` (list(string), default: [])
- `tags` (map(string), default: {})
### Outputs
- `role_arn` (string)
- `role_name` (string)
- `role_id` (string)
### Dependencies
- None

## `kms`
### Inputs
- `enable_data_source_key` (bool, default: false)
- `enable_transient_storage_key` (bool, default: false)
- `enable_multimodal_storage_key` (bool, default: false)
- `enable_vector_store_key` (bool, default: false)
- `deletion_window_in_days` (number, default: 7)
- `key_name_prefix` (string)
- `tags` (map(string), default: {})
### Outputs
- `data_source_key_arn` (string | null)
- `transient_storage_key_arn` (string | null)
- `multimodal_storage_key_arn` (string | null)
- `vector_store_key_arn` (string | null)
### Dependencies
- None

## `logging`
### Inputs
- `enable_cloudwatch_logging` (bool, default: false)
- `enable_s3_logging` (bool, default: false)
- `enable_firehose_logging` (bool, default: false)
- `log_group_name` (string)
- `cloudwatch_retention_in_days` (number, default: 30)
- `s3_bucket_name` (string)
- `firehose_stream_name` (string)
- `tags` (map(string), default: {})
### Outputs
- `cloudwatch_log_group_arn` (string | null)
- `s3_log_bucket_arn` (string | null)
- `firehose_stream_arn` (string | null)
### Dependencies
- None

## `vector-store/opensearch-serverless`
### Inputs
- `collection_name` (string)
- `collection_description` (string, default: "Vector store for Bedrock Knowledge Base")
- `enable_standby_replicas` (bool, default: true)
- `kms_key_arn` (string, default: null)
- `role_arn` (string)
- `vector_index_name` (string, default: "bedrock-knowledge-base-default-index")
- `vector_field_name` (string, default: "bedrock-embedding")
- `vector_dimensions` (number, default: 1024)
- `metadata_field_name` (string, default: "AMAZON_BEDROCK_METADATA")
- `text_field_name` (string, default: "AMAZON_BEDROCK_TEXT_CHUNK")
- `tags` (map(string), default: {})
### Outputs
- `storage_configuration_type` (string)
- `storage_configuration_block` (object)
- `vector_store_id` (string)
- `collection_endpoint` (string)
### Dependencies
- None

## `vector-store/s3-vectors`
### Inputs
- `bucket_name` (string)
- `vector_index_name` (string, default: "default-index")
- `vector_dimensions` (number, default: 1024)
- `distance_metric` (string, default: "cosine")
- `metadata_field_name` (string, default: "metadata")
- `text_field_name` (string, default: "text")
- `kms_key_arn` (string, default: null)
- `tags` (map(string), default: {})
### Outputs
- `storage_configuration_type` (string)
- `storage_configuration_block` (object)
- `vector_store_id` (string)
- `vector_bucket_name` (string)
- `vector_store_arn` (string)
### Dependencies
- None

## `vector-store/aurora-postgresql-serverless`
### Inputs
### Outputs
### Dependencies

## `vector-store/neptune-analytics`
### Inputs
### Outputs
### Dependencies

## `vector-store/external-connection`
### Inputs
### Outputs
### Dependencies

## `knowledge-base-core`
### Inputs
- `kb_name` (string)
- `kb_description` (string, default: "Bedrock Knowledge Base")
- `role_arn` (string)
- `embedding_model_arn` (string)
- `embedding_dimensions` (number, default: 1536)
- `embedding_data_type` (string, default: "FLOAT32")
- `storage_configuration_type` (string)
- `storage_configuration_block` (any)
- `enable_multimodal` (bool, default: false)
- `multimodal_bucket_arn` (string, default: null)
- `kms_key_arn` (string, default: null)
- `tags` (map(string), default: {})
### Outputs
- `knowledge_base_id` (string)
- `knowledge_base_arn` (string)
- `knowledge_base_name` (string)
### Dependencies
- Phase 1 Foundation (`role_arn`)
- Phase 2 Vector Store (`storage_configuration_type`, `storage_configuration_block`)

## `ingestion-config`
### Inputs
- `chunking_strategy` (string, default: "FIXED_SIZE")
- `fixed_size_max_tokens` (number, default: 300)
- `fixed_size_overlap_percentage` (number, default: 20)
- `hierarchical_parent_max_tokens` (number, default: 1500)
- `hierarchical_child_max_tokens` (number, default: 300)
- `hierarchical_overlap_tokens` (number, default: 60)
- `semantic_max_tokens` (number, default: 300)
- `semantic_breakpoint_percentile_threshold` (number, default: 95)
- `parsing_strategy` (string, default: "NONE")
- `parsing_model_arn` (string, default: null)
- `parsing_prompt` (string, default: null)
- `transformation_lambda_arn` (string, default: null)
### Outputs
- `vector_ingestion_configuration` (object)
### Dependencies
- None

## `multimodal-storage`
### Inputs
- `bucket_name` (string)
- `kms_key_arn` (string, default: null)
- `enable_versioning` (bool, default: true)
- `tags` (map(string), default: {})
### Outputs
- `bucket_arn` (string)
- `bucket_name` (string)
- `bucket_uri` (string)
### Dependencies
- None

## `data-source/s3`
### Inputs
- `data_source_name` (string)
- `data_source_description` (string, default: "S3 Data Source for Bedrock KB")
- `knowledge_base_id` (string)
- `s3_bucket_arn` (string)
- `s3_inclusion_prefixes` (list(string), default: [])
- `s3_exclusion_prefixes` (list(string), default: [])
- `kms_key_arn` (string, default: null)
- `deletion_policy` (string, default: "DELETE")
- `tags` (map(string), default: {})
- `chunking_strategy` (string, default: "FIXED_SIZE")
- `parsing_strategy` (string, default: "NONE")
- `parsing_model_arn` (string, default: null)
- (plus all other ingestion-config inputs)
### Outputs
- `data_source_id` (string)
- `data_source_name` (string)
- `data_source_status` (string)
### Dependencies
- Phase 3 Knowledge Base (`knowledge_base_id`)

## `data-source/confluence`
### Inputs
### Outputs
### Dependencies

## `data-source/custom`
### Inputs
- `data_source_name` (string)
- `data_source_description` (string, default: "Custom Data Source for Bedrock KB")
- `knowledge_base_id` (string)
- `kms_key_arn` (string, default: null)
- `deletion_policy` (string, default: "DELETE")
- `tags` (map(string), default: {})
- `chunking_strategy` (string, default: "FIXED_SIZE")
- `parsing_strategy` (string, default: "NONE")
- `parsing_model_arn` (string, default: null)
- (plus all other ingestion-config inputs)
### Outputs
- `data_source_id` (string)
- `data_source_name` (string)
- `data_source_status` (string)
### Dependencies
- Phase 3 Knowledge Base (`knowledge_base_id`)

## `data-source/sharepoint`
### Inputs
### Outputs
### Dependencies

## `data-source/salesforce`
### Inputs
### Outputs
### Dependencies

## `data-source/web-crawler`
### Inputs
### Outputs
### Dependencies
