# CloudWatch
resource "aws_cloudwatch_log_group" "kb_logs" {
  count             = var.enable_cloudwatch_logging ? 1 : 0
  name              = var.log_group_name
  retention_in_days = var.cloudwatch_retention_in_days
  tags              = var.tags
}

# S3 Bucket
resource "aws_s3_bucket" "kb_logs" {
  count         = var.enable_s3_logging ? 1 : 0
  bucket        = var.s3_bucket_name
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_versioning" "kb_logs" {
  count  = var.enable_s3_logging ? 1 : 0
  bucket = aws_s3_bucket.kb_logs[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "kb_logs" {
  count  = var.enable_s3_logging ? 1 : 0
  bucket = aws_s3_bucket.kb_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Firehose IAM Role
data "aws_iam_policy_document" "firehose_assume_role" {
  count = var.enable_firehose_logging ? 1 : 0
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "firehose_role" {
  count              = var.enable_firehose_logging ? 1 : 0
  name               = "${var.firehose_stream_name}-role"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role[0].json
  tags               = var.tags
}

resource "aws_s3_bucket" "firehose_destination" {
  count         = var.enable_firehose_logging ? 1 : 0
  bucket        = "${var.firehose_stream_name}-destination"
  force_destroy = true
  tags          = var.tags
}

data "aws_iam_policy_document" "firehose_s3" {
  count = var.enable_firehose_logging ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]
    resources = [
      aws_s3_bucket.firehose_destination[0].arn,
      "${aws_s3_bucket.firehose_destination[0].arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "firehose_s3" {
  count  = var.enable_firehose_logging ? 1 : 0
  name   = "firehose-s3-access"
  role   = aws_iam_role.firehose_role[0].name
  policy = data.aws_iam_policy_document.firehose_s3[0].json
}

# Firehose
resource "aws_kinesis_firehose_delivery_stream" "kb_logs" {
  count       = var.enable_firehose_logging ? 1 : 0
  name        = var.firehose_stream_name
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role[0].arn
    bucket_arn = aws_s3_bucket.firehose_destination[0].arn
  }

  tags = var.tags
}
