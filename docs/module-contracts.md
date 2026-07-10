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
- `vector_dimensions` (number, default: 1536)
- `metadata_field_name` (string, default: "AMAZON_BEDROCK_METADATA")
- `text_field_name` (string, default: "AMAZON_BEDROCK_TEXT_CHUNK")
- `tags` (map(string), default: {})
### Outputs
- `storage_configuration_type` (string)
- `storage_configuration_block` (object)
- `vector_store_id` (string)
### Dependencies
- None

## `vector-store/s3-vectors`
### Inputs
- `bucket_name` (string)
- `vector_index_name` (string, default: "default-index")
- `vector_dimensions` (number, default: 1536)
- `distance_metric` (string, default: "cosine")
- `metadata_field_name` (string, default: "metadata")
- `text_field_name` (string, default: "text")
- `kms_key_arn` (string, default: null)
- `tags` (map(string), default: {})
### Outputs
- `storage_configuration_type` (string)
- `storage_configuration_block` (object)
- `vector_store_id` (string)
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
### Outputs
### Dependencies

## `ingestion-config`
### Inputs
### Outputs
### Dependencies

## `multimodal-storage`
### Inputs
### Outputs
### Dependencies

## `data-source/s3`
### Inputs
### Outputs
### Dependencies

## `data-source/confluence`
### Inputs
### Outputs
### Dependencies

## `data-source/custom`
### Inputs
### Outputs
### Dependencies

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
