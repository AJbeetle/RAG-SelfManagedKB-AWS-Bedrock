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

data "terraform_remote_state" "foundation" {
  backend = "s3"
  config = {
    bucket = var.state_bucket_name
    key    = "${var.state_key_prefix}/01-foundation/terraform.tfstate"
    region = var.state_region
  }
}

data "terraform_remote_state" "vector_store" {
  backend = "s3"
  config = {
    bucket = var.state_bucket_name
    key    = "${var.state_key_prefix}/02-vector-store/terraform.tfstate"
    region = var.state_region
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
  role_name                      = element(reverse(split("/", local.role_arn)), 0)
  multimodal_storage_kms_key_arn = try(data.terraform_remote_state.foundation.outputs.multimodal_storage_kms_key_arn, null)
  data_source_kms_key_arn        = try(data.terraform_remote_state.foundation.outputs.data_source_kms_key_arn, null)

  storage_type  = data.terraform_remote_state.vector_store.outputs.storage_configuration_type
  storage_block = data.terraform_remote_state.vector_store.outputs.storage_configuration_block
}

module "multimodal_storage" {
  source = "../../../modules/multimodal-storage"
  count  = var.enable_multimodal ? 1 : 0

  bucket_name       = "${local.name_prefix}-multimodal"
  kms_key_arn       = local.multimodal_storage_kms_key_arn
  enable_versioning = true

  tags = local.tags
}

data "aws_iam_policy_document" "multimodal_storage" {
  count = var.enable_multimodal ? 1 : 0

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [module.multimodal_storage[0].bucket_arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = ["${module.multimodal_storage[0].bucket_arn}/*"]
  }
}

resource "aws_iam_role_policy" "multimodal_storage" {
  count = var.enable_multimodal ? 1 : 0

  name   = "${local.name_prefix}-multimodal-storage"
  role   = local.role_name
  policy = data.aws_iam_policy_document.multimodal_storage[0].json
}

resource "terraform_data" "vector_dimensions" {
  input = var.embedding_dimensions

  lifecycle {
    precondition {
      condition     = var.embedding_dimensions == data.terraform_remote_state.vector_store.outputs.vector_dimensions
      error_message = "embedding_dimensions must match the vector index dimensions from phase 2."
    }
  }
}

module "knowledge_base" {
  source = "../../../modules/knowledge-base-core"

  kb_name              = var.kb_name
  role_arn             = local.role_arn
  embedding_model_arn  = var.embedding_model_arn
  embedding_dimensions = var.embedding_dimensions

  storage_configuration_type  = local.storage_type
  storage_configuration_block = local.storage_block

  enable_multimodal     = var.enable_multimodal
  multimodal_bucket_uri = var.enable_multimodal ? module.multimodal_storage[0].bucket_uri : null

  tags = local.tags

  depends_on = [
    aws_iam_role_policy.multimodal_storage,
    terraform_data.vector_dimensions
  ]
}
