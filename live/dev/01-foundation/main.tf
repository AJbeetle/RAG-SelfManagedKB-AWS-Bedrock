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

locals {
  name_prefix = "${var.environment}-${var.project}"
  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

module "kms" {
  source = "../../../modules/kms"

  enable_data_source_key        = var.enable_data_source_key
  enable_transient_storage_key  = var.enable_transient_storage_key
  enable_multimodal_storage_key = var.enable_multimodal_storage_key
  enable_vector_store_key       = var.enable_vector_store_key
  key_name_prefix               = local.name_prefix
  tags                          = local.tags
}

module "iam_runtime_role" {
  source = "../../../modules/iam-runtime-role"

  create_role                = var.create_role
  existing_role_arn          = var.existing_role_arn
  role_name                  = "${local.name_prefix}-runtime-role"
  s3_data_bucket_arns        = var.s3_data_bucket_arns
  enable_secrets_manager     = var.enable_secrets_manager
  transformation_lambda_arns = var.transformation_lambda_arns
  enable_kms_policy          = var.enable_data_source_key || var.enable_transient_storage_key || var.enable_multimodal_storage_key || var.enable_vector_store_key

  kms_key_arns = compact([
    module.kms.data_source_key_arn,
    module.kms.transient_storage_key_arn,
    module.kms.multimodal_storage_key_arn,
    module.kms.vector_store_key_arn
  ])

  tags = local.tags
}

module "logging" {
  source = "../../../modules/logging"

  enable_cloudwatch_logging    = var.enable_cloudwatch_logging
  enable_s3_logging            = var.enable_s3_logging
  enable_firehose_logging      = var.enable_firehose_logging
  
  log_group_name       = "/bedrock/kb/${local.name_prefix}"
  s3_bucket_name       = "${local.name_prefix}-logs"
  firehose_stream_name = "${local.name_prefix}-firehose"
  
  tags = local.tags
}
