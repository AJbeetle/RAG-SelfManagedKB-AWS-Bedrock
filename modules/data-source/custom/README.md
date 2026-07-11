# Bedrock Custom Data Source Module

This module provisions an `aws_bedrockagent_data_source` of type `CUSTOM`. 

A Custom Data Source has no connector-specific configuration (like S3 buckets or Confluence URLs). Instead, you push data directly to it programmatically using the Amazon Bedrock Ingestion API.

## Inputs
- `knowledge_base_id`
- `data_source_name`
- Standard ingestion config variables (`chunking_strategy`, `parsing_strategy`, etc.)

## Outputs
- `data_source_id`
- `data_source_name`
- `data_source_status`
