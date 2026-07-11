terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.24.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}


data "terraform_remote_state" "knowledge_base" {
  backend = "s3"
  config = {
    bucket       = "my-unique-tf-state-bucket-name-20hph2602"
    key          = "live/dev/03-knowledge-base/terraform.tfstate"
    region       = "us-east-1"
    profile      = "AJ-PHP-LZ"
  }
}


module "s3_data_source" {
  source = "../../../../modules/data-source/s3"

  knowledge_base_id = data.terraform_remote_state.knowledge_base.outputs.knowledge_base_id
  data_source_name  = var.data_source_name
  s3_bucket_arn     = var.s3_bucket_arn
  
  # Add this line here!
  s3_inclusion_prefixes = var.s3_inclusion_prefixes
  
  
  chunking_strategy = var.chunking_strategy
  parsing_strategy  = var.parsing_strategy
  parsing_model_arn = var.parsing_model_arn
  
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
