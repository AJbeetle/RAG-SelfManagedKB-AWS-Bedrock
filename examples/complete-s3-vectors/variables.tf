variable "region" {
  type        = string
  description = "AWS region for all resources"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Short environment identifier"
  default     = "dev"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,11}$", var.environment))
    error_message = "environment must be 1-12 lowercase alphanumeric or hyphen characters."
  }
}

variable "project" {
  type        = string
  description = "Short project identifier used in resource names"
  default     = "bedrock-kb"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,19}$", var.project))
    error_message = "project must be 2-20 lowercase alphanumeric or hyphen characters."
  }
}

variable "s3_data_bucket_arn" {
  type        = string
  description = "ARN of an existing S3 bucket containing source documents"

  validation {
    condition     = can(regex("^arn:[^:]+:s3:::[^/]+$", var.s3_data_bucket_arn))
    error_message = "s3_data_bucket_arn must be a bucket ARN without an object suffix."
  }
}

variable "s3_inclusion_prefixes" {
  type        = list(string)
  description = "Optional S3 prefixes included during ingestion"
  default     = []
}

variable "embedding_model_id" {
  type        = string
  description = "Bedrock embedding model identifier"
  default     = "amazon.titan-embed-text-v2:0"
}

variable "embedding_dimensions" {
  type        = number
  description = "Embedding and vector index dimensions"
  default     = 1024
}

variable "vector_index_name" {
  type        = string
  description = "Name of the S3 Vectors index"
  default     = "bedrock-index"
}

variable "enable_customer_managed_kms" {
  type        = bool
  description = "Encrypt the data source and vector bucket with customer-managed KMS keys"
  default     = true
}

variable "chunking_strategy" {
  type        = string
  description = "Bedrock chunking strategy"
  default     = "FIXED_SIZE"

  validation {
    condition     = contains(["FIXED_SIZE", "HIERARCHICAL", "SEMANTIC", "NONE"], var.chunking_strategy)
    error_message = "chunking_strategy must be FIXED_SIZE, HIERARCHICAL, SEMANTIC, or NONE."
  }
}

variable "data_deletion_policy" {
  type        = string
  description = "Whether Bedrock deletes or retains indexed data when the data source is removed"
  default     = "DELETE"

  validation {
    condition     = contains(["DELETE", "RETAIN"], var.data_deletion_policy)
    error_message = "data_deletion_policy must be DELETE or RETAIN."
  }
}
