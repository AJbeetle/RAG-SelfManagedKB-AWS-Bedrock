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


module "s3_data_source" {
  source = "../../../../modules/data-source/s3"

  knowledge_base_id = data.terraform_remote_state.knowledge_base.outputs.knowledge_base_id
  data_source_name  = var.data_source_name
  s3_bucket_arn     = var.s3_bucket_arn
  kms_key_arn       = try(data.terraform_remote_state.knowledge_base.outputs.data_source_kms_key_arn, null)

  s3_inclusion_prefixes = var.s3_inclusion_prefixes

  chunking_strategy = var.chunking_strategy
  parsing_strategy  = var.parsing_strategy
  parsing_model_arn = var.parsing_model_arn
}
