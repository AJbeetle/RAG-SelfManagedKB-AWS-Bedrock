output "state_bucket_name" {
  value       = aws_s3_bucket.terraform_state.id
  description = "The name of the S3 bucket storing Terraform state"
}

output "lock_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table for state locking"
}


output "authenticated_account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "The AWS Account ID currently authenticated via the profile"
}