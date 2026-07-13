# Amazon Bedrock Self-Managed Knowledge Base Accelerator

Version `0.1.0`

This accelerator provisions an Amazon Bedrock Knowledge Base backed by infrastructure that you manage through Terraform. It provides a tested S3 Vectors golden path, an OpenSearch Serverless staged profile, reusable modules, pinned provider locks, automated verification, and a deterministic release package.

## Supported Paths

| Capability | Status | Deployment |
|---|---|---|
| S3 Vectors knowledge base | Tested golden path | `examples/complete-s3-vectors` |
| OpenSearch Serverless knowledge base | Supported staged path | `live/dev` plus the OpenSearch example profile |
| S3 data source | Supported | Golden and staged paths |
| Custom API-push data source | Supported | Staged path |
| Fixed, hierarchical, semantic, and no chunking | Supported | Reusable data-source modules |
| Foundation-model and Bedrock Data Automation parsing | Supported by module contract | Reusable data-source modules |
| Customer-managed KMS encryption | Supported | Data sources, S3 Vectors, OpenSearch, and multimodal S3 |
| Multimodal supplemental storage | Supported | Staged path |
| Confluence, SharePoint, Salesforce, and web crawler | Roadmap only | Not included in this release |
| Aurora, Neptune Analytics, and external vector stores | Roadmap only | Not included in this release |

Do not use empty roadmap module directories as customer interfaces. Only the paths marked supported above are part of the artifact contract.

## Reproducibility Contract

The repository fixes the following inputs to make customer deployments repeatable:

- Terraform CLI used by CI: `1.8.1`, declared in `.terraform-version`.
- AWS provider used by executable roots: `6.54.0`, selected by committed lock files.
- OpenSearch provider for the staged path: `2.3.2`, selected by its lock file.
- Every executable root is initialized with a read-only dependency lock during verification.
- No AWS profile, account ID, state bucket, source bucket, or credentials are committed.
- `make check` runs the same validation contract locally and in CI.
- `make package` creates a deterministic ZIP with an embedded file-hash manifest and external SHA-256 checksum.

See [ARTIFACT.md](ARTIFACT.md) for the packaging and verification contract.

## Prerequisites

- Terraform `1.8.1` for byte-for-byte parity with CI. Modules accept Terraform `>= 1.5.0, < 2.0.0`.
- TFLint `0.60.0` when running the complete local verification suite.
- Python 3.9 or later for deterministic packaging.
- AWS credentials provided through the standard AWS credential chain.
- Permission to create IAM roles and policies, KMS keys, Bedrock resources, S3 Vectors or OpenSearch Serverless resources, and the selected state backend.
- An existing general-purpose S3 bucket containing source documents.
- Access to the selected Bedrock embedding model in the target region.

Authentication is intentionally outside Terraform configuration. For example:

```bash
export AWS_PROFILE=customer-sandbox
export AWS_REGION=us-east-1
aws sts get-caller-identity
```

CI should use an assumed role or workload identity instead of static credentials.

## Verify the Source

Run the complete local contract before deploying:

```bash
make check
```

This command performs:

1. `terraform fmt -check -recursive`
2. recursive TFLint
3. provider initialization with committed, read-only lock files
4. `terraform validate` for every executable root
5. Terraform tests for ingestion configuration, knowledge-base storage, and the complete S3 Vectors example

These checks do not create AWS resources or require AWS credentials.

## Quick Start: Complete S3 Vectors

The complete example creates the runtime role, KMS keys, S3 Vectors bucket and index, knowledge base, and S3 data source in one state.

### 1. Create the remote state backend

Bootstrap uses local state intentionally because the remote backend does not yet exist:

```bash
cd bootstrap/backend-bootstrap
cp terraform.tfvars.example terraform.tfvars
```

Set globally unique values for `state_bucket_name` and `lock_table_name`, then run:

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
terraform output
cd ../..
```

Protect the bootstrap state because it owns the shared state bucket and lock table.

### 2. Configure the golden path

```bash
cd examples/complete-s3-vectors
cp backend.s3.tfbackend.example backend.s3.tfbackend
cp terraform.tfvars.example terraform.tfvars
```

Set these customer-specific values:

- `backend.s3.tfbackend`: state bucket, DynamoDB lock table, state region, and state key.
- `terraform.tfvars`: existing document bucket ARN, region, environment, and project name.

Bucket inputs must be bucket ARNs without an object suffix:

```hcl
s3_data_bucket_arn = "arn:aws:s3:::customer-document-bucket"
```

Use `s3_inclusion_prefixes` for paths inside the bucket.

### 3. Plan and apply

```bash
terraform init -backend-config=backend.s3.tfbackend
terraform plan -out=tfplan
terraform apply tfplan
```

The example derives globally unique vector-bucket naming from the account ID, region, environment, and project.

### 4. Start ingestion

Terraform creates the data source but does not start an ingestion job:

```bash
aws bedrock-agent start-ingestion-job \
  --knowledge-base-id "$(terraform output -raw knowledge_base_id)" \
  --data-source-id "$(terraform output -raw data_source_id)" \
  --region "${AWS_REGION:-us-east-1}"
```

Monitor the job in the Bedrock console or with the Bedrock Agent API, then test retrieval against the knowledge base.

## OpenSearch Serverless Profile

OpenSearch Serverless uses separate AWS and OpenSearch provider operations, so the accelerator exposes it through staged states:

```text
bootstrap
  -> live/dev/01-foundation
  -> live/dev/02-vector-store
  -> live/dev/03-knowledge-base
  -> live/dev/04-data-sources/s3-docs
```

Use the configuration profile in [examples/minimal-s3-opensearch-serverless](examples/minimal-s3-opensearch-serverless). Copy each numbered `.tfvars.example` file to its matching staged root as `terraform.tfvars`.

Each staged root contains a `backend.s3.tfbackend.example`. Copy it to `backend.s3.tfbackend`, set a unique state key, and initialize with:

```bash
terraform init -backend-config=backend.s3.tfbackend
```

Deploy phases in numeric order. Downstream phases read only documented outputs from upstream remote state.

## Repository Layout

```text
.
├── bootstrap/backend-bootstrap/        # S3 state bucket and DynamoDB lock table
├── examples/
│   ├── complete-s3-vectors/            # Tested, single-state golden path
│   └── minimal-s3-opensearch-serverless/ # Staged OpenSearch configuration profile
├── live/dev/                           # Independently managed production-style stages
├── modules/
│   ├── data-source/{s3,custom}/
│   ├── iam-runtime-role/
│   ├── ingestion-config/
│   ├── kms/
│   ├── knowledge-base-core/
│   ├── logging/
│   ├── multimodal-storage/
│   └── vector-store/{s3-vectors,opensearch-serverless}/
├── scripts/                            # Validation, tests, and deterministic packaging
├── ARTIFACT.md
├── Makefile
└── VERSION
```

Detailed reusable-module inputs and outputs are documented in [docs/module-contracts.md](docs/module-contracts.md).

## Security Behavior

- Runtime-role trust is limited to the Bedrock service.
- S3 document permissions separate bucket-level `ListBucket` from object-level `GetObject`.
- S3 Vectors permissions are scoped to the generated vector index ARN.
- Multimodal permissions are scoped to the generated supplemental bucket.
- KMS permissions are scoped to the generated keys when customer-managed encryption is enabled.
- Backend and provider credentials use the ambient AWS credential chain and are never packaged.
- Actual `.tfvars`, `.tfbackend`, state files, plans, `.terraform`, and Git metadata are excluded from release artifacts.

The OpenSearch Serverless module currently allows public network access so Bedrock and the Terraform OpenSearch provider can reach the collection. Customers requiring private-only access must supply their VPC endpoint and service-access design before production use.

## Build the Release Artifact

```bash
make package
```

Successful output is written to `dist/`:

```text
bedrock-self-managed-kb-accelerator-0.1.0.zip
bedrock-self-managed-kb-accelerator-0.1.0.zip.sha256
```

Verify it with:

```bash
cd dist
shasum -a 256 -c bedrock-self-managed-kb-accelerator-0.1.0.zip.sha256
```

GitHub Actions runs the same command and publishes both files as workflow artifacts.

## Upgrade Rules

- Change provider constraints intentionally and refresh every affected root lock file with `terraform init -upgrade`.
- Run `make check` after any module, example, lock, or documentation change.
- Increment `VERSION` using semantic versioning before distributing a new customer artifact.
- Treat removed or renamed inputs, outputs, resources, or state keys as breaking changes.
- Review Terraform plans when changing vector backends; switching backends replaces the vector store and requires knowledge-base and data-source recreation.

## Destroy and Retention

Review `data_deletion_policy` before destroying a data source:

- `DELETE` removes indexed content managed by the data source.
- `RETAIN` leaves indexed content behind.

The source document bucket is an input and is never deleted by the accelerator. KMS keys use a deletion window. OpenSearch Serverless and S3 Vectors can incur charges until their resources are destroyed.

Destroy in reverse dependency order for staged deployments. For the complete example:

```bash
cd examples/complete-s3-vectors
terraform destroy
```

## Troubleshooting

| Symptom | Check |
|---|---|
| `s3:ListBucket` denied | Supply the bucket ARN without `/*` and reapply the runtime-role policy. |
| Knowledge-base dimension error | Keep `embedding_dimensions` identical to the vector index dimensions. |
| S3 Vectors access denied | Confirm the generated runtime-role policy contains the five `s3vectors` index actions. |
| OpenSearch `no such index` | Complete phase 2 successfully before applying phase 3. |
| Backend lock error | Confirm the DynamoDB table name and state region in `backend.s3.tfbackend`. |
| Parsing model rejected | Provide a supported model ARN in the same region and ensure the runtime role can invoke it. |
| Chunking change rejected | Chunking and parsing are immutable; recreate the data source. |

## Customer Extension Boundary

Fork the accelerator when adding organization-specific networking, permission boundaries, mandatory tags, SCP-aware IAM, cross-account buckets, or additional data-source connectors. Keep those changes in composition roots where possible; reusable modules should retain provider-neutral inputs and explicit outputs.
