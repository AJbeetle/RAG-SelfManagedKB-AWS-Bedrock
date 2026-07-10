variable "enable_data_source_key" {
  type        = bool
  description = "Enable KMS key for data sources"
  default     = false
}

variable "enable_transient_storage_key" {
  type        = bool
  description = "Enable KMS key for transient storage"
  default     = false
}

variable "enable_multimodal_storage_key" {
  type        = bool
  description = "Enable KMS key for multimodal storage"
  default     = false
}

variable "enable_vector_store_key" {
  type        = bool
  description = "Enable KMS key for vector store"
  default     = false
}

variable "deletion_window_in_days" {
  type        = number
  description = "Duration in days after which the key is deleted after destruction of the resource"
  default     = 7
}

variable "key_name_prefix" {
  type        = string
  description = "Prefix for KMS key aliases"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
