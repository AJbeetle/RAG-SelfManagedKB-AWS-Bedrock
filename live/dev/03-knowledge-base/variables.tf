variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "state_bucket_name" {
  type        = string
  description = "S3 bucket containing the foundation and vector-store Terraform states"
}

variable "state_region" {
  type        = string
  description = "AWS region containing the Terraform state bucket"
  default     = "us-east-1"
}

variable "state_key_prefix" {
  type        = string
  description = "Key prefix shared by the staged Terraform states"
  default     = "live/dev"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, prod)"
}

variable "project" {
  type        = string
  description = "Project name"
}

variable "kb_name" {
  type        = string
  description = "Name of the Bedrock Knowledge Base"
}

variable "embedding_model_arn" {
  type        = string
  description = "ARN of the embedding foundation model"
}

variable "embedding_dimensions" {
  type        = number
  description = "Dimensions of the vector embeddings"
  default     = 1536
}

variable "enable_multimodal" {
  type        = bool
  description = "Enable supplemental data storage for multimodal extraction"
  default     = false
}
