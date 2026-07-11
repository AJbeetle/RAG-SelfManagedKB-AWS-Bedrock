variable "aws_profile" {
  type        = string
  description = "AWS CLI profile to use"
  default     = "default"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "s3_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket containing the documents"
}

variable "s3_inclusion_prefixes" {
  type        = list(string)
  description = "List of prefixes to include"
  default     = []
}

variable "data_source_name" {
  type        = string
  description = "Name of the Bedrock data source"
  default     = "dev-s3-docs"
}

variable "chunking_strategy" {
  type        = string
  default     = "FIXED_SIZE"
}
