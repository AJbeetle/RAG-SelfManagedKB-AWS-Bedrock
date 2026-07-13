output "data_source_id" {
  description = "The ID of the data source"
  value       = aws_bedrockagent_data_source.this.data_source_id
}

output "data_source_name" {
  description = "The name of the data source"
  value       = aws_bedrockagent_data_source.this.name
}
