variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket for multimodal (supplemental data) storage"
}

variable "kms_key_arn" {
  type        = string
  description = "Optional KMS key ARN for encrypting the multimodal bucket"
  default     = null
}

variable "enable_versioning" {
  type        = bool
  description = "Whether to enable versioning on the multimodal bucket"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
