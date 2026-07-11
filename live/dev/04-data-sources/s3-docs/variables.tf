variable "aws_profile" {
  type        = string
  description = "AWS CLI profile to use"
  default     = "default"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "s3_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket containing the documents"
}

variable "s3_inclusion_prefixes" {
  type        = list(string)
  description = "List of prefixes to include"
  default     = []
}

variable "data_source_name" {
  type        = string
  description = "Name of the Bedrock data source"
  default     = "dev-s3-docs"
}

variable "chunking_strategy" {
  type        = string
  description = "Chunking strategy (FIXED_SIZE, HIERARCHICAL, SEMANTIC, NONE)"
  default     = "FIXED_SIZE"
}

variable "parsing_strategy" {
  type        = string
  description = "Parsing strategy (BEDROCK_DATA_AUTOMATION, BEDROCK_FOUNDATION_MODEL, NONE)"
  default     = "NONE"
}

variable "parsing_model_arn" {
  type        = string
  description = "Model ARN for BEDROCK_FOUNDATION_MODEL parsing strategy"
  default     = null
}
