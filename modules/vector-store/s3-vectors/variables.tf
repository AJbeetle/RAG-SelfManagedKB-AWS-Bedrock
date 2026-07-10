variable "bucket_name" {
  type        = string
  description = "Name of the S3 Vectors bucket"
}

variable "vector_index_name" {
  type        = string
  description = "Name of the vector index"
  default     = "default-index"
}

variable "vector_dimensions" {
  type        = number
  description = "Dimensions of the vector"
  default     = 1536
}

variable "distance_metric" {
  type        = string
  description = "Distance metric (e.g., cosine, euclidean, dotproduct)"
  default     = "cosine"
}

variable "metadata_field_name" {
  type        = string
  description = "Name of the field mapping to the metadata"
  default     = "metadata"
}

variable "text_field_name" {
  type        = string
  description = "Name of the field mapping to the text"
  default     = "text"
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of the KMS key for encryption"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
