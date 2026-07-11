terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.54.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

data "terraform_remote_state" "foundation" {
  backend = "s3"
  config = {
    bucket       = "my-unique-tf-state-bucket-name-20hph2602"
    key          = "live/dev/01-foundation/terraform.tfstate"
    region       = "us-east-1"
    profile      = "AJ-PHP-LZ"
  }
}

data "terraform_remote_state" "vector_store" {
  backend = "s3"
  config = {
    bucket       = "my-unique-tf-state-bucket-name-20hph2602"
    key          = "live/dev/02-vector-store/terraform.tfstate"
    region       = "us-east-1"
    profile      = "AJ-PHP-LZ"
  }
}

locals {
  name_prefix = "${var.environment}-${var.project}"
  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
  
  role_arn                       = data.terraform_remote_state.foundation.outputs.role_arn
  multimodal_storage_kms_key_arn = data.terraform_remote_state.foundation.outputs.multimodal_storage_kms_key_arn
  data_source_kms_key_arn        = data.terraform_remote_state.foundation.outputs.data_source_kms_key_arn
  
  storage_type  = data.terraform_remote_state.vector_store.outputs.storage_configuration_type
  storage_block = data.terraform_remote_state.vector_store.outputs.storage_configuration_block
}

module "multimodal_storage" {
  source = "../../../modules/multimodal-storage"
  count  = var.enable_multimodal ? 1 : 0

  bucket_name       = "${local.name_prefix}-multimodal"
  kms_key_arn       = local.multimodal_storage_kms_key_arn != "" ? local.multimodal_storage_kms_key_arn : null
  enable_versioning = true
  
  tags = local.tags
}

module "knowledge_base" {
  source = "../../../modules/knowledge-base-core"

  kb_name                     = var.kb_name
  role_arn                    = local.role_arn
  embedding_model_arn         = var.embedding_model_arn
  embedding_dimensions        = var.embedding_dimensions
  
  storage_configuration_type  = local.storage_type
  storage_configuration_block = local.storage_block
  
  enable_multimodal           = var.enable_multimodal
  multimodal_bucket_arn       = var.enable_multimodal ? module.multimodal_storage[0].bucket_arn : null
  kms_key_arn                 = local.data_source_kms_key_arn != "" ? local.data_source_kms_key_arn : null

  tags = local.tags
}
