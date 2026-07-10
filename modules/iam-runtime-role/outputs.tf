output "role_arn" {
  value = var.create_role ? aws_iam_role.bedrock_kb[0].arn : var.existing_role_arn
}

output "role_name" {
  value = var.create_role ? aws_iam_role.bedrock_kb[0].name : split("/", var.existing_role_arn)[length(split("/", var.existing_role_arn)) - 1]
}

output "role_id" {
  value = var.create_role ? aws_iam_role.bedrock_kb[0].unique_id : null
}
