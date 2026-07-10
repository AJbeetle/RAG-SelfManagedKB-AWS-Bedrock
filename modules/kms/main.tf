# Data Source Key
resource "aws_kms_key" "data_source" {
  count                   = var.enable_data_source_key ? 1 : 0
  description             = "Encrypts data source content for Bedrock KB"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true
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
  tags                    = var.tags
}

resource "aws_kms_alias" "vector_store" {
  count         = var.enable_vector_store_key ? 1 : 0
  name          = "alias/${var.key_name_prefix}-vector-store"
  target_key_id = aws_kms_key.vector_store[0].key_id
}
