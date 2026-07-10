output "cloudwatch_log_group_arn" {
  value = var.enable_cloudwatch_logging ? aws_cloudwatch_log_group.kb_logs[0].arn : null
}

output "s3_log_bucket_arn" {
  value = var.enable_s3_logging ? aws_s3_bucket.kb_logs[0].arn : null
}

output "firehose_stream_arn" {
  value = var.enable_firehose_logging ? aws_kinesis_firehose_delivery_stream.kb_logs[0].arn : null
}
