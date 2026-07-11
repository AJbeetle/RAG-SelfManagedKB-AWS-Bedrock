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
  
  validation {
    # Guard against using BINARY with Titan v1 or other models that don't support it
    condition     = !(var.embedding_data_type == "BINARY" && length(regexall(".*amazon\\.titan-embed-text-v1.*", var.embedding_model_arn)) > 0)
    error_message = "BINARY embedding data type is not supported by Titan Embed V1. Please use FLOAT32 or upgrade to a newer model."
  }
}

variable "storage_configuration_type" {
  type        = string
  description = "The vector store type (e.g. OPENSEARCH_SERVERLESS, S3_VECTORS)"
}

variable "storage_configuration_block" {
  type        = any
  description = "The detailed storage configuration block provided by the vector store module"
}

variable "enable_multimodal" {
  type        = bool
  description = "Enable supplemental data storage for multimodal extraction"
  default     = false
}

variable "multimodal_bucket_arn" {
  type        = string
  description = "S3 bucket ARN for multimodal supplemental storage"
  default     = null
}

variable "kms_key_arn" {
  type        = string
  description = "Optional KMS key ARN for encrypting the knowledge base"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
