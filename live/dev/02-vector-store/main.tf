terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.54.0"
    }
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "~> 2.2"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

provider "opensearch" {
  url         = var.vector_store_type == "opensearch-serverless" ? module.opensearch_serverless[0].collection_endpoint : "https://dummy.us-east-1.aoss.amazonaws.com"
  aws_profile = var.aws_profile
  # Authentication is handled automatically via AWS credentials from environment/profile if healthcheck is configured
  healthcheck = false
  # SigV4 is required for AOSS
  # aws_signature_version = "v4"
  sign_aws_requests = true
  aws_region = var.region
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
  
  providers = {
    opensearch = opensearch
  }

  collection_name         = "${local.name_prefix}-oss"
  enable_standby_replicas = var.enable_standby_replicas
  kms_key_arn             = local.kms_key_arn != "" ? local.kms_key_arn : null
  role_arn                = local.role_arn
  vector_index_name       = var.vector_index_name
  vector_dimensions       = var.vector_dimensions
  
  tags = local.tags
}

module "s3_vectors" {
  source = "../../../modules/vector-store/s3-vectors"
  count  = var.vector_store_type == "s3-vectors" ? 1 : 0

  bucket_name       = "${local.name_prefix}-s3v"
  kms_key_arn       = local.kms_key_arn != "" ? local.kms_key_arn : null
  vector_index_name = var.vector_index_name
  vector_dimensions = var.vector_dimensions

  tags = local.tags
}
