variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "state_bucket_name" {
  type        = string
  description = "S3 bucket containing the foundation Terraform state"
}

variable "state_region" {
  type        = string
  description = "AWS region containing the Terraform state bucket"
  default     = "us-east-1"
}

variable "state_key_prefix" {
  type        = string
  description = "Key prefix shared by the staged Terraform states"
  default     = "live/dev"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, prod)"
}

variable "project" {
  type        = string
  description = "Project name"
}

variable "vector_store_type" {
  type        = string
  description = "Which vector store module to use (opensearch-serverless, s3-vectors)"
  default     = "opensearch-serverless"

  validation {
    condition     = contains(["opensearch-serverless", "s3-vectors"], var.vector_store_type)
    error_message = "vector_store_type must be opensearch-serverless or s3-vectors."
  }
}

variable "enable_standby_replicas" {
  type        = bool
  description = "Enable redundancy for OSS"
  default     = false
}

variable "vector_index_name" {
  type        = string
  description = "Name of the vector index"
  default     = "bedrock-index"
}

variable "vector_dimensions" {
  type        = number
  description = "Dimensions of the vector index"
  default     = 1024
}

variable "collection_name" {
  type        = string
  description = "Unique identifier for the vector store collection"
}

# For S3 vectors and opensearch

variable "metadata_field_name" {
  type        = string
  description = "Name of the field mapping to the metadata"
  default     = "AMAZON_BEDROCK_METADATA" # default metadata field name that needs to be put in unfiltered key in s3 or opensearch vector index
}

variable "text_field_name" {
  type        = string
  description = "Name of the field mapping to the text"
  default     = "AMAZON_BEDROCK_TEXT" # default text field  name - to be put in unfiltered key in s3 or opensearch vector index
}
