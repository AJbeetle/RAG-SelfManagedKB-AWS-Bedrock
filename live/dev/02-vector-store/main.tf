terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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
    bucket  = "my-unique-tf-state-bucket-name-20hph2602"
    key     = "live/dev/01-foundation/terraform.tfstate"
    region  = "us-east-1"
    profile = "AJ-PHP-LZ"
  }
}

locals {
  name_prefix = "${var.environment}-${var.project}"
  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
  
  # Read values from foundation state
  role_arn    = data.terraform_remote_state.foundation.outputs.role_arn
  kms_key_arn = data.terraform_remote_state.foundation.outputs.vector_store_kms_key_arn
}

module "opensearch_serverless" {
  source = "../../../modules/vector-store/opensearch-serverless"
  count  = var.vector_store_type == "opensearch-serverless" ? 1 : 0

  collection_name         = "${local.name_prefix}-oss"
  enable_standby_replicas = var.enable_standby_replicas
  kms_key_arn             = local.kms_key_arn != "" ? local.kms_key_arn : null
  role_arn                = local.role_arn
  vector_index_name       = var.vector_index_name
  
  tags = local.tags
}

module "s3_vectors" {
  source = "../../../modules/vector-store/s3-vectors"
  count  = var.vector_store_type == "s3-vectors" ? 1 : 0

  bucket_name       = "${local.name_prefix}-s3v"
  kms_key_arn       = local.kms_key_arn != "" ? local.kms_key_arn : null
  vector_index_name = var.vector_index_name

  tags = local.tags
}
