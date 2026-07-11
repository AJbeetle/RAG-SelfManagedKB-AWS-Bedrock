locals {
  selected_module_type = var.vector_store_type == "opensearch-serverless" ? module.opensearch_serverless[0] : module.s3_vectors[0]
}

output "storage_configuration_type" {
  value       = local.selected_module_type.storage_configuration_type
  description = "The vector store type"
}

output "storage_configuration_block" {
  value       = local.selected_module_type.storage_configuration_block
  description = "The storage configuration block"
}

output "vector_store_id" {
  value       = try(module.opensearch_serverless[0].vector_store_id, module.s3_vectors[0].vector_store_arn, null)
  description = "The vector store ID"
}
