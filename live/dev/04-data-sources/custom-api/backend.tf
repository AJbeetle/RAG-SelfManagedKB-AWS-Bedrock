terraform {
  backend "s3" {
    bucket         = "my-unique-tf-state-bucket-name-20hph2602"
    key            = "live/dev/04-data-sources/custom-api/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile   = true
    encrypt        = true
    profile        = "AJ-PHP-LZ"
  }
}
