terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.54.0, < 7.0.0"
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "bedrock_key_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowBedrock"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:CreateGrant"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "vector_store_key_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowBedrockAndVectorStores"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com", "indexing.s3vectors.amazonaws.com", "aoss.amazonaws.com"]
    }
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:CreateGrant"
    ]
    resources = ["*"]
  }
}

# Data Source Key
resource "aws_kms_key" "data_source" {
  count                   = var.enable_data_source_key ? 1 : 0
  description             = "Encrypts data source content for Bedrock KB"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.bedrock_key_policy.json
  tags                    = var.tags
}

resource "aws_kms_alias" "data_source" {
  count         = var.enable_data_source_key ? 1 : 0
  name          = "alias/${var.key_name_prefix}-data-source"
  target_key_id = aws_kms_key.data_source[0].key_id
}

# Transient Storage Key
resource "aws_kms_key" "transient_storage" {
  count                   = var.enable_transient_storage_key ? 1 : 0
  description             = "Encrypts transient storage content for Bedrock KB"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.bedrock_key_policy.json
  tags                    = var.tags
}

resource "aws_kms_alias" "transient_storage" {
  count         = var.enable_transient_storage_key ? 1 : 0
  name          = "alias/${var.key_name_prefix}-transient-storage"
  target_key_id = aws_kms_key.transient_storage[0].key_id
}

# Multimodal Storage Key
resource "aws_kms_key" "multimodal_storage" {
  count                   = var.enable_multimodal_storage_key ? 1 : 0
  description             = "Encrypts multimodal storage content for Bedrock KB"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.bedrock_key_policy.json
  tags                    = var.tags
}

resource "aws_kms_alias" "multimodal_storage" {
  count         = var.enable_multimodal_storage_key ? 1 : 0
  name          = "alias/${var.key_name_prefix}-multimodal-storage"
  target_key_id = aws_kms_key.multimodal_storage[0].key_id
}

# Vector Store Key
resource "aws_kms_key" "vector_store" {
  count                   = var.enable_vector_store_key ? 1 : 0
  description             = "Encrypts vector store content for Bedrock KB"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.vector_store_key_policy.json
  tags                    = var.tags
}

resource "aws_kms_alias" "vector_store" {
  count         = var.enable_vector_store_key ? 1 : 0
  name          = "alias/${var.key_name_prefix}-vector-store"
  target_key_id = aws_kms_key.vector_store[0].key_id
}
