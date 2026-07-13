output "knowledge_base_id" {
  value       = module.knowledge_base.knowledge_base_id
  description = "Bedrock Knowledge Base ID"
}

output "data_source_id" {
  value       = module.s3_data_source.data_source_id
  description = "Bedrock data source ID"
}

output "vector_index_arn" {
  value       = module.s3_vectors.vector_index_arn
  description = "S3 Vectors index ARN"
}

output "runtime_role_arn" {
  value       = module.runtime_role.role_arn
  description = "Bedrock runtime role ARN"
}
