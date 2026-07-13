variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, prod)"
}

variable "project" {
  type        = string
  description = "Project name"
}

variable "create_role" {
  type        = bool
  description = "Whether to create a new IAM role or use an existing one"
  default     = true
}

variable "existing_role_arn" {
  type        = string
  description = "ARN of an existing IAM role to use if create_role is false"
  default     = ""
}

variable "s3_data_bucket_arns" {
  type        = list(string)
  description = "List of S3 bucket ARNs to grant read access to"
  default     = []
}

variable "enable_secrets_manager" {
  type        = bool
  description = "Whether to grant Secrets Manager access for connector authentication"
  default     = false
}

variable "transformation_lambda_arns" {
  type        = list(string)
  description = "List of Lambda ARNs to grant invoke access to"
  default     = []
}

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

variable "enable_cloudwatch_logging" {
  type        = bool
  description = "Enable CloudWatch logging"
  default     = false
}

variable "enable_s3_logging" {
  type        = bool
  description = "Enable S3 logging"
  default     = false
}

variable "enable_firehose_logging" {
  type        = bool
  description = "Enable Firehose delivery stream logging"
  default     = false
}
