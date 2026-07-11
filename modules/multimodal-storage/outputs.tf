output "bucket_arn" {
  value       = aws_s3_bucket.multimodal.arn
  description = "The ARN of the multimodal storage S3 bucket"
}

output "bucket_name" {
  value       = aws_s3_bucket.multimodal.id
  description = "The name of the multimodal storage S3 bucket"
}

output "bucket_uri" {
  value       = "s3://${aws_s3_bucket.multimodal.id}"
  description = "The S3 URI of the multimodal storage bucket, for use as supplementalDataStorageConfiguration"
}
