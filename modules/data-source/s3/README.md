# Bedrock S3 Data Source Module

This module provisions an `aws_bedrockagent_data_source` of type `S3`. It uses the shared `ingestion-config` submodule to ensure standardized chunking and parsing configurations.

## Immutability Guard ⚠️

> **Important:** Chunking and parsing strategies are immutable in Amazon Bedrock once a data source is created. Attempting to change them in-place will result in an API error. If you need to change the chunking or parsing strategy, you must destroy and recreate the data source.

## Inputs
- `knowledge_base_id`
- `data_source_name`
- `s3_bucket_arn` (The ARN of the pre-existing S3 bucket containing your documents)
- Standard ingestion config variables (`chunking_strategy`, `parsing_strategy`, etc.)

## Outputs
- `data_source_id`
- `data_source_name`
