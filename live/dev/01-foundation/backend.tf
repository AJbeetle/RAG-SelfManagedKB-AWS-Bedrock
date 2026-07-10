terraform {
  backend "s3" {
    bucket         = "my-unique-tf-state-bucket-name-20hph2602"
    key            = "live/dev/01-foundation/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "my-tf-lock-table-aayushi-20hph"
    encrypt        = true
    profile        = "AJ-PHP-LZ"
  }
}
