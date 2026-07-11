# Ingestion Config Submodule

This module is a pure configuration generator. It creates no resources itself, but standardizes the `vectorIngestionConfiguration` block used by every Bedrock Data Source module.

## Immutability Guard ⚠️

> **Important:** Chunking and parsing strategies are immutable in Amazon Bedrock once a data source is created. Attempting to change them in-place will result in an API error. If you need to change the chunking or parsing strategy, you must destroy and recreate the data source, or create a new one.

To enforce this, we recommend downstream modules pass this configuration to `aws_bedrockagent_data_source` inside a block that ignores changes or uses `create_before_destroy`.

## Usage

```hcl
module "ingestion_config" {
  source = "../../ingestion-config"
  
  chunking_strategy = "FIXED_SIZE"
  fixed_size_max_tokens = 500
  
  parsing_strategy = "BEDROCK_FOUNDATION_MODEL"
  parsing_model_arn = "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-haiku-20240307-v1:0"
}
```
