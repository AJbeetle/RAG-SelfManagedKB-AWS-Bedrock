terraform {
  required_version = ">= 1.5.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.54.0, < 7.0.0"
    }
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = ">= 2.3.0, < 3.0.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "opensearch" {
  url = var.vector_store_type == "opensearch-serverless" ? module.opensearch_serverless[0].collection_endpoint : "https://dummy.${var.region}.aoss.amazonaws.com"
  # Authentication is handled via the ambient AWS credential chain
  healthcheck = false
  
  # AWS SigV4 authentication is required for OpenSearch Serverless
  sign_aws_requests = true
  aws_region        = var.region
}

data "terraform_remote_state" "foundation" {
  backend = "s3"
  config = {
    bucket = var.state_bucket_name
    key    = "${var.state_key_prefix}/01-foundation/terraform.tfstate"
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

  # Read values from foundation state
  role_arn    = data.terraform_remote_state.foundation.outputs.role_arn
  role_name   = element(reverse(split("/", local.role_arn)), 0)
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

data "aws_iam_policy_document" "s3_vectors_access" {
  count = var.vector_store_type == "s3-vectors" ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "s3vectors:DeleteVectors",
      "s3vectors:GetIndex",
      "s3vectors:GetVectors",
      "s3vectors:PutVectors",
      "s3vectors:QueryVectors"
    ]
    resources = [module.s3_vectors[0].vector_index_arn]
  }
}

resource "aws_iam_role_policy" "s3_vectors_access" {
  count = var.vector_store_type == "s3-vectors" ? 1 : 0

  name   = "${local.name_prefix}-s3-vectors-access"
  role   = local.role_name
  policy = data.aws_iam_policy_document.s3_vectors_access[0].json
}
