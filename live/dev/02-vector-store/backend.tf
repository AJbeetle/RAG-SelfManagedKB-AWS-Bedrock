terraform {
  backend "s3" {
    bucket         = "my-unique-tf-state-bucket-name-20hph2602"
    key            = "live/dev/02-vector-store/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile   = true
    encrypt        = true
    profile        = "AJ-PHP-LZ"
  }
}
