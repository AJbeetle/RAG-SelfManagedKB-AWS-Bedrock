mock_provider "aws" {
  override_data {
    target = data.aws_caller_identity.current
    values = {
      account_id = "123456789012"
    }
  }

  override_data {
    target = data.aws_iam_policy_document.s3_vectors_access
    values = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  override_data {
    target = module.runtime_role.data.aws_iam_policy_document.bedrock_trust[0]
    values = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  override_data {
    target = module.runtime_role.data.aws_iam_policy_document.s3_access[0]
    values = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  override_data {
    target = module.runtime_role.data.aws_iam_policy_document.kms[0]
    values = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  override_data {
    target = module.runtime_role.data.aws_iam_policy_document.kb_core[0]
    values = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

run "plans_complete_s3_vectors_stack" {
  command = plan

  variables {
    s3_data_bucket_arn = "arn:aws:s3:::test-document-bucket"
  }

  assert {
    condition     = module.s3_vectors.storage_configuration_type == "S3_VECTORS"
    error_message = "The golden path did not configure S3 Vectors storage."
  }

  assert {
    condition     = module.s3_data_source.data_source_name == "dev-bedrock-kb-documents"
    error_message = "The golden path did not configure an S3 data source."
  }
}
