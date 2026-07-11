variable "chunking_strategy" {
  type        = string
  description = "Chunking strategy: FIXED_SIZE, HIERARCHICAL, SEMANTIC, or NONE"
  default     = "FIXED_SIZE"

  validation {
    condition     = contains(["FIXED_SIZE", "HIERARCHICAL", "SEMANTIC", "NONE"], var.chunking_strategy)
    error_message = "chunking_strategy must be FIXED_SIZE, HIERARCHICAL, SEMANTIC, or NONE."
  }
}

variable "fixed_size_max_tokens" {
  type        = number
  description = "Max tokens for FIXED_SIZE chunking"
  default     = 300
}

variable "fixed_size_overlap_percentage" {
  type        = number
  description = "Overlap percentage for FIXED_SIZE chunking"
  default     = 20
}

variable "hierarchical_parent_max_tokens" {
  type        = number
  description = "Parent max tokens for HIERARCHICAL chunking"
  default     = 1500
}

variable "hierarchical_child_max_tokens" {
  type        = number
  description = "Child max tokens for HIERARCHICAL chunking"
  default     = 300
}

variable "hierarchical_overlap_tokens" {
  type        = number
  description = "Overlap tokens for HIERARCHICAL chunking"
  default     = 60
}

variable "semantic_max_tokens" {
  type        = number
  description = "Max tokens for SEMANTIC chunking"
  default     = 300
}

variable "semantic_breakpoint_percentile_threshold" {
  type        = number
  description = "Breakpoint percentile threshold for SEMANTIC chunking"
  default     = 95
}

variable "semantic_buffer_size" {
  type        = number
  description = "Buffer size for SEMANTIC chunking"
  default     = 0
}

variable "parsing_strategy" {
  type        = string
  description = "Parsing strategy: BEDROCK_DATA_AUTOMATION, BEDROCK_FOUNDATION_MODEL, or NONE"
  default     = "NONE"

  validation {
    condition     = contains(["BEDROCK_DATA_AUTOMATION", "BEDROCK_FOUNDATION_MODEL", "NONE"], var.parsing_strategy)
    error_message = "parsing_strategy must be BEDROCK_DATA_AUTOMATION, BEDROCK_FOUNDATION_MODEL, or NONE."
  }
}

variable "parsing_model_arn" {
  type        = string
  description = "Model ARN for BEDROCK_FOUNDATION_MODEL parsing strategy"
  default     = null
}

variable "parsing_prompt" {
  type        = string
  description = "Optional custom prompt for BEDROCK_FOUNDATION_MODEL parsing"
  default     = null
}

variable "transformation_lambda_arn" {
  type        = string
  description = "Optional Lambda ARN for custom transformation"
  default     = null
}
