output "data_source_id" {
  value       = module.s3_data_source.data_source_id
  description = "The ID of the S3 data source"
}

output "data_source_name" {
  value       = module.s3_data_source.data_source_name
  description = "The name of the S3 data source"
}
