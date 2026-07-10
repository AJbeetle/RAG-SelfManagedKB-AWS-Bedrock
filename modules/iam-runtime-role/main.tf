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
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = flatten([
      for arn in var.s3_data_bucket_arns : [arn, "${arn}/*"]
    ])
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
