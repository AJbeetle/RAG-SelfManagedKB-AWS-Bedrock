terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.54.0, < 7.0.0"
    }
  }
}

data "aws_iam_policy_document" "bedrock_trust" {
  count = var.create_role ? 1 : 0
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "bedrock_kb" {
  count              = var.create_role ? 1 : 0
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.bedrock_trust[0].json
  tags               = var.tags
}

data "aws_iam_policy_document" "s3_access" {
  count = var.create_role && length(var.s3_data_bucket_arns) > 0 ? 1 : 0

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = var.s3_data_bucket_arns
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = [for arn in var.s3_data_bucket_arns : "${arn}/*"]
  }
}

resource "aws_iam_policy" "s3_access" {
  count  = var.create_role && length(var.s3_data_bucket_arns) > 0 ? 1 : 0
  name   = "${var.role_name}-s3-access"
  policy = data.aws_iam_policy_document.s3_access[0].json
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  count      = var.create_role && length(var.s3_data_bucket_arns) > 0 ? 1 : 0
  role       = aws_iam_role.bedrock_kb[0].name
  policy_arn = aws_iam_policy.s3_access[0].arn
}

data "aws_iam_policy_document" "secrets_manager" {
  count = var.create_role && var.enable_secrets_manager ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = ["*"] # ideally scoped down
  }
}

resource "aws_iam_policy" "secrets_manager" {
  count  = var.create_role && var.enable_secrets_manager ? 1 : 0
  name   = "${var.role_name}-secrets-manager"
  policy = data.aws_iam_policy_document.secrets_manager[0].json
}

resource "aws_iam_role_policy_attachment" "secrets_manager" {
  count      = var.create_role && var.enable_secrets_manager ? 1 : 0
  role       = aws_iam_role.bedrock_kb[0].name
  policy_arn = aws_iam_policy.secrets_manager[0].arn
}

data "aws_iam_policy_document" "kms" {
  count = var.create_role && var.enable_kms_policy ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey"
    ]
    resources = var.kms_key_arns
  }
}

resource "aws_iam_policy" "kms" {
  count  = var.create_role && var.enable_kms_policy ? 1 : 0
  name   = "${var.role_name}-kms"
  policy = data.aws_iam_policy_document.kms[0].json
}

resource "aws_iam_role_policy_attachment" "kms" {
  count      = var.create_role && var.enable_kms_policy ? 1 : 0
  role       = aws_iam_role.bedrock_kb[0].name
  policy_arn = aws_iam_policy.kms[0].arn
}

data "aws_iam_policy_document" "lambda_invoke" {
  count = var.create_role && length(var.transformation_lambda_arns) > 0 ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = var.transformation_lambda_arns
  }
}

resource "aws_iam_policy" "lambda_invoke" {
  count  = var.create_role && length(var.transformation_lambda_arns) > 0 ? 1 : 0
  name   = "${var.role_name}-lambda-invoke"
  policy = data.aws_iam_policy_document.lambda_invoke[0].json
}

resource "aws_iam_role_policy_attachment" "lambda_invoke" {
  count      = var.create_role && length(var.transformation_lambda_arns) > 0 ? 1 : 0
  role       = aws_iam_role.bedrock_kb[0].name
  policy_arn = aws_iam_policy.lambda_invoke[0].arn
}

# --- Core Permissions Required by Bedrock KB ---
data "aws_iam_policy_document" "kb_core" {
  count = var.create_role ? 1 : 0

  # Permission to invoke the embedding model
  statement {
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel",
    ]
    resources = [
      "arn:aws:bedrock:*::foundation-model/*"
    ]
  }

  # Permission to hit the OpenSearch Serverless collection data plane
  # (Since Foundation is deployed before OSS, we use wildcard. Bedrock requires this to validate the vector store)
  statement {
    effect = "Allow"
    actions = [
      "aoss:APIAccessAll"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "kb_core" {
  count  = var.create_role ? 1 : 0
  name   = "${var.role_name}-core-perms"
  policy = data.aws_iam_policy_document.kb_core[0].json
}

resource "aws_iam_role_policy_attachment" "kb_core" {
  count      = var.create_role ? 1 : 0
  role       = aws_iam_role.bedrock_kb[0].name
  policy_arn = aws_iam_policy.kb_core[0].arn
}
