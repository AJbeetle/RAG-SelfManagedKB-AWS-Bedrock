# Complete S3 Vectors Example

This is the accelerator's tested golden path. It creates, in one Terraform state:

- two optional customer-managed KMS keys;
- the Bedrock runtime role and scoped policies;
- an S3 Vectors bucket and index;
- a Bedrock Knowledge Base; and
- an S3 data source connected to an existing document bucket.

## Deploy

```bash
cp backend.s3.tfbackend.example backend.s3.tfbackend
cp terraform.tfvars.example terraform.tfvars
```

Set the backend bucket, lock table, and source document bucket, then run:

```bash
terraform init -backend-config=backend.s3.tfbackend
terraform plan -out=tfplan
terraform apply tfplan
```

Start the first ingestion job from the Bedrock console or API after the apply completes.

## Destroy

```bash
terraform destroy
```

The existing source document bucket is never managed or deleted by this example.
