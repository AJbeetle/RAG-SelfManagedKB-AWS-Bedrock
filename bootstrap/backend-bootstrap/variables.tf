variable "region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}

variable "state_bucket_name" {
  type        = string
  description = "Name of the S3 bucket to store Terraform state"
}

variable "lock_table_name" {
  type        = string
  description = "Name of the DynamoDB table for state locking"
}
