terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.54.0, < 7.0.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "terraform_remote_state" "knowledge_base" {
  backend = "s3"
  config = {
    bucket = var.state_bucket_name
    key    = "${var.state_key_prefix}/03-knowledge-base/terraform.tfstate"
    region = var.state_region
  }
}

module "custom_data_source" {
  source = "../../../../modules/data-source/custom"

  knowledge_base_id = data.terraform_remote_state.knowledge_base.outputs.knowledge_base_id
  data_source_name  = var.data_source_name
  kms_key_arn       = try(data.terraform_remote_state.knowledge_base.outputs.data_source_kms_key_arn, null)

  chunking_strategy = var.chunking_strategy
  parsing_strategy  = var.parsing_strategy
  parsing_model_arn = var.parsing_model_arn
  parsing_prompt    = var.parsing_prompt
  deletion_policy   = var.deletion_policy

  fixed_size_max_tokens                    = var.fixed_size_max_tokens
  fixed_size_overlap_percentage            = var.fixed_size_overlap_percentage
  hierarchical_parent_max_tokens           = var.hierarchical_parent_max_tokens
  hierarchical_child_max_tokens            = var.hierarchical_child_max_tokens
  hierarchical_overlap_tokens              = var.hierarchical_overlap_tokens
  semantic_max_tokens                      = var.semantic_max_tokens
  semantic_breakpoint_percentile_threshold = var.semantic_breakpoint_percentile_threshold
}
