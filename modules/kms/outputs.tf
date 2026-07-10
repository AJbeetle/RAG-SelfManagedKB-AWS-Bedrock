output "data_source_key_arn" {
  value = var.enable_data_source_key ? aws_kms_key.data_source[0].arn : null
}

output "transient_storage_key_arn" {
  value = var.enable_transient_storage_key ? aws_kms_key.transient_storage[0].arn : null
}

output "multimodal_storage_key_arn" {
  value = var.enable_multimodal_storage_key ? aws_kms_key.multimodal_storage[0].arn : null
}

output "vector_store_key_arn" {
  value = var.enable_vector_store_key ? aws_kms_key.vector_store[0].arn : null
}
