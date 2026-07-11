variable "collection_name" {
  type        = string
  description = "Name of the OpenSearch Serverless collection"
}

variable "collection_description" {
  type        = string
  description = "Description of the OpenSearch Serverless collection"
  default     = "Vector store for Bedrock Knowledge Base"
}

variable "enable_standby_replicas" {
  type        = bool
  description = "Enable redundancy (active replicas) for the collection"
  default     = true
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of the KMS key for encryption. If null, AWS-owned key is used."
  default     = null
}

variable "role_arn" {
  type        = string
  description = "ARN of the Bedrock KB runtime role to grant data access"
}

variable "vector_index_name" {
  type        = string
  description = "Name of the vector index to create"
  default     = "bedrock-knowledge-base-default-index"
}

variable "vector_field_name" {
  type        = string
  description = "Name of the field mapping to the vector"
  default     = "bedrock-embedding"
}

variable "vector_dimensions" {
  type        = number
  description = "Number of dimensions for the vector field"
  default     = 1024 # 1536 for Amazon Titan Embeddings G1 - Text, but use 1024 It covers mostly vector store indexes vector dimensions and mostly embedding models too
}

variable "metadata_field_name" {
  type        = string
  description = "Name of the field mapping to the metadata"
  default     = "AMAZON_BEDROCK_METADATA"
}

variable "text_field_name" {
  type        = string
  description = "Name of the field mapping to the text"
  default     = "AMAZON_BEDROCK_TEXT_CHUNK"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
