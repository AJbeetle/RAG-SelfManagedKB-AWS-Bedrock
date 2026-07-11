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

variable "data_source_name" {
  type        = string
  description = "Name of the Bedrock data source"
  default     = "dev-custom-api"
}

variable "chunking_strategy" {
  type        = string
  default     = "FIXED_SIZE"
}
