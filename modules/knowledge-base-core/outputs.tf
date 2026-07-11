output "knowledge_base_id" {
  value       = aws_bedrockagent_knowledge_base.this.id
  description = "The ID of the Knowledge Base"
}

output "knowledge_base_arn" {
  value       = aws_bedrockagent_knowledge_base.this.arn
  description = "The ARN of the Knowledge Base"
}

output "knowledge_base_name" {
  value       = aws_bedrockagent_knowledge_base.this.name
  description = "The name of the Knowledge Base"
}
