output "knowledge_base_id" {
  value       = module.knowledge_base.knowledge_base_id
  description = "The ID of the Knowledge Base"
}

output "knowledge_base_arn" {
  value       = module.knowledge_base.knowledge_base_arn
  description = "The ARN of the Knowledge Base"
}

output "knowledge_base_name" {
  value       = module.knowledge_base.knowledge_base_name
  description = "The name of the Knowledge Base"
}

output "data_source_kms_key_arn" {
  value       = local.data_source_kms_key_arn
  description = "KMS key ARN to use for downstream data-source encryption"
}
