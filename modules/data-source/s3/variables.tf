variable "data_source_name" {
  type        = string
  description = "Name of the Bedrock data source"
}

variable "data_source_description" {
  type        = string
  description = "Description of the data source"
  default     = "S3 Data Source for Bedrock KB"
}

variable "knowledge_base_id" {
  type        = string
  description = "ID of the Knowledge Base"
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

variable "s3_exclusion_prefixes" {
  type        = list(string)
  description = "List of prefixes to exclude"
  default     = []
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key ARN for encrypting the data source"
  default     = null
}

variable "deletion_policy" {
  type        = string
  description = "Data deletion policy: DELETE or RETAIN"
  default     = "DELETE"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply"
  default     = {}
}

# Ingestion config variables
variable "chunking_strategy" {
  type    = string
  default = "FIXED_SIZE"
}
variable "fixed_size_max_tokens" {
  type    = number
  default = 300
}
variable "fixed_size_overlap_percentage" {
  type    = number
  default = 20
}
variable "hierarchical_parent_max_tokens" {
  type    = number
  default = 1500
}
variable "hierarchical_child_max_tokens" {
  type    = number
  default = 300
}
variable "hierarchical_overlap_tokens" {
  type    = number
  default = 60
}
variable "semantic_max_tokens" {
  type    = number
  default = 300
}
variable "semantic_breakpoint_percentile_threshold" {
  type    = number
  default = 95
}
variable "parsing_strategy" {
  type    = string
  default = "NONE"
}
variable "parsing_model_arn" {
  type    = string
  default = null
}
variable "parsing_prompt" {
  type    = string
  default = null
}
variable "transformation_lambda_arn" {
  type    = string
  default = null
}
