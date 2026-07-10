variable "aws_profile" {
  type        = string
  description = "The local AWS CLI profile to use for authentication"
}

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

variable "vector_store_type" {
  type        = string
  description = "Which vector store module to use (opensearch-serverless, s3-vectors)"
  default     = "opensearch-serverless"
}

variable "enable_standby_replicas" {
  type        = bool
  description = "Enable redundancy for OSS"
  default     = false
}

variable "vector_index_name" {
  type        = string
  description = "Name of the vector index"
  default     = "bedrock-index"
}
