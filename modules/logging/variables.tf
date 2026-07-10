variable "enable_cloudwatch_logging" {
  type        = bool
  description = "Enable CloudWatch logging for Bedrock KB"
  default     = false
}

variable "enable_s3_logging" {
  type        = bool
  description = "Enable S3 logging for Bedrock KB"
  default     = false
}

variable "enable_firehose_logging" {
  type        = bool
  description = "Enable Firehose delivery stream for Bedrock KB logging"
  default     = false
}

variable "log_group_name" {
  type        = string
  description = "Name for the CloudWatch log group"
}

variable "cloudwatch_retention_in_days" {
  type        = number
  description = "Retention period for CloudWatch logs"
  default     = 30
}

variable "s3_bucket_name" {
  type        = string
  description = "Name for the S3 log bucket"
}

variable "firehose_stream_name" {
  type        = string
  description = "Name for the Firehose delivery stream"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
