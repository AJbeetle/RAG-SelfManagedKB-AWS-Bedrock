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

variable "role_name" {
  type        = string
  description = "Name for the IAM role"
}

variable "s3_data_bucket_arns" {
  type        = list(string)
  description = "List of S3 bucket ARNs, without object suffixes, to grant read access to"
  default     = []

  validation {
    condition = alltrue([
      for arn in var.s3_data_bucket_arns : can(regex("^arn:[^:]+:s3:::[^/]+$", arn))
    ])
    error_message = "s3_data_bucket_arns must contain bucket ARNs without /* object suffixes."
  }
}

variable "enable_secrets_manager" {
  type        = bool
  description = "Whether to grant Secrets Manager access for connector authentication"
  default     = false
}

variable "kms_key_arns" {
  type        = list(string)
  description = "List of KMS key ARNs to grant encrypt/decrypt access to"
  default     = []
}

variable "transformation_lambda_arns" {
  type        = list(string)
  description = "List of Lambda ARNs to grant invoke access to"
  default     = []
}

variable "enable_kms_policy" {
  type        = bool
  description = "Whether to create the KMS policy attachment"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
