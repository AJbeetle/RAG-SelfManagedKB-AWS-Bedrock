output "role_arn" {
  value       = module.iam_runtime_role.role_arn
  description = "ARN of the Knowledge Base IAM runtime role"
}

output "data_source_kms_key_arn" {
  value       = module.kms.data_source_key_arn
  description = "ARN of the data source KMS key"
}

output "transient_storage_kms_key_arn" {
  value       = module.kms.transient_storage_key_arn
  description = "ARN of the transient storage KMS key"
}

output "multimodal_storage_kms_key_arn" {
  value       = module.kms.multimodal_storage_key_arn
  description = "ARN of the multimodal storage KMS key"
}

output "vector_store_kms_key_arn" {
  value       = module.kms.vector_store_key_arn
  description = "ARN of the vector store KMS key"
}

output "cloudwatch_log_group_arn" {
  value       = module.logging.cloudwatch_log_group_arn
  description = "ARN of the CloudWatch log group"
}

output "s3_log_bucket_arn" {
  value       = module.logging.s3_log_bucket_arn
  description = "ARN of the S3 log bucket"
}

output "firehose_stream_arn" {
  value       = module.logging.firehose_stream_arn
  description = "ARN of the Firehose delivery stream"
}
