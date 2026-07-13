variable "kb_name" {
  type        = string
  description = "Name of the Bedrock Knowledge Base"
}

variable "kb_description" {
  type        = string
  description = "Description of the Knowledge Base"
  default     = "Bedrock Knowledge Base"
}

variable "role_arn" {
  type        = string
  description = "IAM Role ARN for the Knowledge Base"
}

variable "embedding_model_arn" {
  type        = string
  description = "ARN of the embedding foundation model"
}

variable "embedding_dimensions" {
  type        = number
  description = "Dimensions of the vector embeddings"
  default     = 1536

  validation {
    condition     = var.embedding_dimensions >= 1 && var.embedding_dimensions <= 4096
    error_message = "embedding_dimensions must be between 1 and 4096."
  }
}

variable "embedding_data_type" {
  type        = string
  description = "Data type of the vectors (FLOAT32 or BINARY)"
  default     = "FLOAT32"

  validation {
    condition     = contains(["FLOAT32", "BINARY"], var.embedding_data_type)
    error_message = "embedding_data_type must be either FLOAT32 or BINARY."
  }
}

variable "storage_configuration_type" {
  type        = string
  description = "The vector store type (e.g. OPENSEARCH_SERVERLESS, S3_VECTORS)"

  validation {
    condition     = contains(["OPENSEARCH_SERVERLESS", "S3_VECTORS"], var.storage_configuration_type)
    error_message = "storage_configuration_type must be OPENSEARCH_SERVERLESS or S3_VECTORS."
  }
}

variable "storage_configuration_block" {
  type = object({
    opensearch_serverless_configuration = optional(object({
      collection_arn    = string
      vector_index_name = string
      field_mapping = object({
        vector_field   = string
        text_field     = string
        metadata_field = string
      })
    }))
    s3_vectors_configuration = optional(object({
      index_arn = string
    }))
  })
  description = "The detailed storage configuration block provided by the vector store module"
}

variable "enable_multimodal" {
  type        = bool
  description = "Enable supplemental data storage for multimodal extraction"
  default     = false
}

variable "multimodal_bucket_uri" {
  type        = string
  description = "S3 URI for multimodal supplemental storage"
  default     = null

  validation {
    condition     = var.multimodal_bucket_uri == null ? true : startswith(var.multimodal_bucket_uri, "s3://")
    error_message = "multimodal_bucket_uri must be an S3 URI beginning with s3://."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
