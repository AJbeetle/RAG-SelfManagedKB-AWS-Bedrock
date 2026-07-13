data "aws_caller_identity" "current" {}

locals {
  name_prefix = "${var.environment}-${var.project}"
  tags = {
    Accelerator = "bedrock-self-managed-kb"
    Environment = var.environment
    Project     = var.project
  }

  vector_bucket_name = substr(
    "${local.name_prefix}-${data.aws_caller_identity.current.account_id}-${var.region}-vectors",
    0,
    63
  )
  embedding_model_arn = "arn:aws:bedrock:${var.region}::foundation-model/${var.embedding_model_id}"
}

module "kms" {
  source = "../../modules/kms"

  enable_data_source_key  = var.enable_customer_managed_kms
  enable_vector_store_key = var.enable_customer_managed_kms
  key_name_prefix         = local.name_prefix
  tags                    = local.tags
}

module "runtime_role" {
  source = "../../modules/iam-runtime-role"

  role_name           = "${local.name_prefix}-runtime-role"
  s3_data_bucket_arns = [var.s3_data_bucket_arn]
  enable_kms_policy   = var.enable_customer_managed_kms
  kms_key_arns = compact([
    module.kms.data_source_key_arn,
    module.kms.vector_store_key_arn
  ])
  tags = local.tags
}

module "s3_vectors" {
  source = "../../modules/vector-store/s3-vectors"

  bucket_name       = local.vector_bucket_name
  vector_index_name = var.vector_index_name
  vector_dimensions = var.embedding_dimensions
  kms_key_arn       = module.kms.vector_store_key_arn
  tags              = local.tags
}

data "aws_iam_policy_document" "s3_vectors_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3vectors:DeleteVectors",
      "s3vectors:GetIndex",
      "s3vectors:GetVectors",
      "s3vectors:PutVectors",
      "s3vectors:QueryVectors"
    ]
    resources = [module.s3_vectors.vector_index_arn]
  }
}

resource "aws_iam_role_policy" "s3_vectors_access" {
  name   = "${local.name_prefix}-s3-vectors-access"
  role   = module.runtime_role.role_name
  policy = data.aws_iam_policy_document.s3_vectors_access.json
}

module "knowledge_base" {
  source = "../../modules/knowledge-base-core"

  kb_name                     = "${local.name_prefix}-kb"
  role_arn                    = module.runtime_role.role_arn
  embedding_model_arn         = local.embedding_model_arn
  embedding_dimensions        = var.embedding_dimensions
  storage_configuration_type  = module.s3_vectors.storage_configuration_type
  storage_configuration_block = module.s3_vectors.storage_configuration_block
  tags                        = local.tags

  depends_on = [aws_iam_role_policy.s3_vectors_access]
}

module "s3_data_source" {
  source = "../../modules/data-source/s3"

  knowledge_base_id     = module.knowledge_base.knowledge_base_id
  data_source_name      = "${local.name_prefix}-documents"
  s3_bucket_arn         = var.s3_data_bucket_arn
  s3_inclusion_prefixes = var.s3_inclusion_prefixes
  kms_key_arn           = module.kms.data_source_key_arn
  deletion_policy       = var.data_deletion_policy
  chunking_strategy     = var.chunking_strategy
}
