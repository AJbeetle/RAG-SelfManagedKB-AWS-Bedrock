run "uses_explicit_intermediate_storage" {
  command = plan

  variables {
    transformation_lambda_arn               = "arn:aws:lambda:us-east-1:123456789012:function:transform"
    transformation_intermediate_storage_uri = "s3://test-transform-bucket/intermediate/"
  }

  assert {
    condition     = output.vector_ingestion_configuration.custom_transformation_configuration.intermediate_storage.s3_location.uri == "s3://test-transform-bucket/intermediate/"
    error_message = "Custom transformation configuration did not preserve the supplied intermediate storage URI."
  }
}
