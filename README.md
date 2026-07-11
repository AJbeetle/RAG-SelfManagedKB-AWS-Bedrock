# Bedrock Self-Managed Knowledge Base Terraform Repository

This repository provisions **Amazon Bedrock Self-Managed Knowledge Bases** via Terraform, specifically tailored for unstructured data RAG pipelines.

## Prerequisites
- **Terraform:** v1.5.0 or higher
- **AWS Provider:** v6.54.0 or higher
- **AWS Credentials:** Configured via standard AWS mechanisms (e.g., `~/.aws/credentials`, `AWS_ACCESS_KEY_ID`, SSO, etc.)

## Quick Start
To bootstrap a new environment, deploy in the following order:
1. **Foundation:** `cd live/dev/01-foundation` -> `terraform apply`
2. **Vector Store:** `cd live/dev/02-vector-store` -> `terraform apply`
3. **Knowledge Base:** `cd live/dev/03-knowledge-base` -> `terraform apply`
4. **Data Sources:** `cd live/dev/04-data-sources/<source-name>` -> `terraform apply`

For more detailed module inputs and outputs, please see [docs/module-contracts.md](docs/module-contracts.md).

---

## Repository Structure

```
RAG-terra/
├── bootstrap/backend-bootstrap/   # Creates the S3 state bucket (local state — intentional)
├── modules/                        # Reusable Terraform modules
│   ├── iam-runtime-role/           # Bedrock KB runtime IAM role
│   ├── kms/                        # Four independently-toggleable KMS keys
│   ├── logging/                    # CloudWatch, S3, and Firehose logging destinations
│   ├── vector-store/
│   │   ├── opensearch-serverless/  # OpenSearch Serverless collection + vector index
│   │   └── s3-vectors/            # S3 Vectors bucket + vector index
│   ├── knowledge-base-core/        # aws_bedrockagent_knowledge_base resource
│   ├── multimodal-storage/         # Supplemental S3 bucket for multimodal data
│   ├── ingestion-config/           # Pure config generator for chunking/parsing
│   └── data-source/
│       ├── s3/                     # S3 data source connector
│       └── custom/                 # Custom (API-push) data source connector
├── live/dev/                       # Composition layers (one per phase)
│   ├── 01-foundation/
│   ├── 02-vector-store/
│   ├── 03-knowledge-base/
│   └── 04-data-sources/
│       ├── s3-docs/                # Each data source gets its own state
│       └── custom-api/
└── docs/                           # Phase plans, contracts, architecture docs
```

## Deployment Order

Phases **must** be deployed in order because each phase consumes outputs from the previous one via `terraform_remote_state`:

```
bootstrap → 01-foundation → 02-vector-store → 03-knowledge-base → 04-data-sources/*
```

All state files (except bootstrap) are stored in the S3 bucket with encryption enabled and lock files for concurrency safety.

---

## Phase 1 — Foundation (`live/dev/01-foundation`)

### What It Creates
- **IAM Runtime Role** — A service role trusted by `bedrock.amazonaws.com` with scoped policies for S3, KMS, Secrets Manager, and Lambda
- **KMS Keys** — Up to four independently-toggleable encryption keys (data source, transient storage, multimodal storage, vector store)
- **Logging Destinations** — Up to three logging backends (CloudWatch, S3 bucket, Firehose stream)

### Configurable Variables (`terraform.tfvars`)

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_profile` | string | *required* | AWS CLI profile name |
| `region` | string | `us-east-1` | AWS region |
| `environment` | string | *required* | Environment name (e.g., `dev`, `prod`) |
| `project` | string | *required* | Project name (used in resource naming) |
| `create_role` | bool | `true` | Create a new IAM role or use an existing one |
| `existing_role_arn` | string | `""` | ARN of existing role (only when `create_role = false`) |
| `s3_data_bucket_arns` | list(string) | `[]` | S3 bucket ARNs the KB role can read (**must include both bucket and `/*`**) |
| `enable_secrets_manager` | bool | `false` | Grant Secrets Manager access (for Confluence/SharePoint connectors) |
| `transformation_lambda_arns` | list(string) | `[]` | Lambda ARNs the role can invoke |
| `enable_data_source_key` | bool | `false` | Create KMS key for data source encryption |
| `enable_transient_storage_key` | bool | `false` | Create KMS key for transient storage |
| `enable_multimodal_storage_key` | bool | `false` | Create KMS key for multimodal storage |
| `enable_vector_store_key` | bool | `false` | Create KMS key for vector store |
| `enable_cloudwatch_logging` | bool | `false` | Create CloudWatch log group |
| `enable_s3_logging` | bool | `false` | Create S3 logging bucket |
| `enable_firehose_logging` | bool | `false` | Create Firehose delivery stream |

### Current Active Configuration

```hcl
aws_profile = "AJ-PHP-LZ"
region      = "us-east-1"
environment = "dev"
project     = "bedrock-kb"

create_role = true
s3_data_bucket_arns = [
  "arn:aws:s3:::aws-kb-test1-data-store-aj-20hph",
  "arn:aws:s3:::aws-kb-test1-data-store-aj-20hph/*"
]
enable_secrets_manager     = false
transformation_lambda_arns = []

enable_data_source_key        = true
enable_transient_storage_key  = false
enable_multimodal_storage_key = true
enable_vector_store_key       = true

enable_cloudwatch_logging = true
enable_s3_logging         = false
enable_firehose_logging   = false
```

### Outputs Consumed by Downstream Phases
| Output | Consumed By |
|--------|-------------|
| `role_arn` | Phase 2 (vector store access policies), Phase 3 (KB resource) |
| `data_source_kms_key_arn` | Phase 3 (KB encryption) |
| `vector_store_kms_key_arn` | Phase 2 (vector store encryption) |
| `multimodal_storage_kms_key_arn` | Phase 3 (multimodal bucket encryption) |
| `cloudwatch_log_group_arn` | Phase 3 (KB logging — future wiring) |

### Deploy

```bash
cd live/dev/01-foundation
terraform init
terraform plan
terraform apply
```

> **⚠️ Important:** When you add a new S3 data source in Phase 4, you must come back here and add the bucket ARN to `s3_data_bucket_arns`, then re-apply. Otherwise the data source sync will fail with `403 Forbidden`.

---

## Phase 2 — Vector Store (`live/dev/02-vector-store`)

### What It Creates
One of the following (controlled by `vector_store_type`):
- **OpenSearch Serverless** — A VECTORSEARCH collection with encryption/network/access policies and a FAISS-engine vector index
- **S3 Vectors** — An S3 Vectors bucket with a vector index (lightweight, cost-effective alternative)

### Configurable Variables (`terraform.tfvars`)

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_profile` | string | *required* | AWS CLI profile name |
| `region` | string | `us-east-1` | AWS region |
| `environment` | string | *required* | Environment name |
| `project` | string | *required* | Project name |
| `vector_store_type` | string | `opensearch-serverless` | Which backend to use: `opensearch-serverless` or `s3-vectors` |
| `enable_standby_replicas` | bool | `false` | Enable active replicas for OSS (increases cost) |
| `vector_index_name` | string | `bedrock-index` | Name of the vector index |
| `vector_dimensions` | number | `1024` | Dimensions of the vector index (must match embedding model) |

### Current Active Configuration

```hcl
aws_profile = "AJ-PHP-LZ"
region      = "us-east-1"
environment = "dev"
project     = "bedrock-kb"

vector_store_type       = "s3-vectors"
enable_standby_replicas = false
vector_index_name       = "bedrock-index-new"
```

### Outputs Consumed by Downstream Phases
| Output | Consumed By |
|--------|-------------|
| `storage_configuration_type` | Phase 3 (KB storage type) |
| `storage_configuration_block` | Phase 3 (KB storage config — collection ARN, field mappings, etc.) |
| `vector_store_id` | Informational |

### Deploy

```bash
cd live/dev/02-vector-store
terraform init
terraform plan
terraform apply
```

> **⚠️ Important:** If you switch `vector_store_type` from `opensearch-serverless` to `s3-vectors` (or vice versa), Terraform will destroy the old vector store and create a new one. You will also need to re-apply Phase 3 (Knowledge Base) and recreate your data sources (Phase 4). The vector dimensions must match the embedding model dimensions used in Phase 3.

---

## Phase 3 — Knowledge Base (`live/dev/03-knowledge-base`)

### What It Creates
- **`aws_bedrockagent_knowledge_base`** — The core Bedrock Knowledge Base resource, wired to the embedding model and vector store
- **Multimodal Storage S3 Bucket** *(optional)* — For storing extracted images/audio/video from multimodal documents

### Configurable Variables (`terraform.tfvars`)

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_profile` | string | *required* | AWS CLI profile name |
| `region` | string | `us-east-1` | AWS region |
| `environment` | string | *required* | Environment name |
| `project` | string | *required* | Project name |
| `kb_name` | string | *required* | Name of the Knowledge Base (visible in Bedrock console) |
| `embedding_model_arn` | string | *required* | ARN of the foundation model for embeddings |
| `embedding_dimensions` | number | `1536` | Vector embedding dimensions (**must match Phase 2's `vector_dimensions`**) |
| `enable_multimodal` | bool | `false` | Enable supplemental data storage for multimodal extraction |

### Current Active Configuration

```hcl
aws_profile = "AJ-PHP-LZ"
region      = "us-east-1"
environment = "dev"
project     = "bedrock-kb"

kb_name              = "dev-bedrock-kb"
embedding_model_arn  = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"
embedding_dimensions = 1024
enable_multimodal    = false
```

### Supported Embedding Models

| Model | ARN | Default Dimensions |
|-------|-----|-------------------|
| Titan Embed Text v2 | `arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0` | 1024 |
| Titan Embed Text v1 | `arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v1` | 1536 |
| Cohere Embed English | `arn:aws:bedrock:us-east-1::foundation-model/cohere.embed-english-v3` | 1024 |
| Cohere Embed Multilingual | `arn:aws:bedrock:us-east-1::foundation-model/cohere.embed-multilingual-v3` | 1024 |

### Outputs Consumed by Downstream Phases
| Output | Consumed By |
|--------|-------------|
| `knowledge_base_id` | Phase 4 (every data source) |
| `knowledge_base_arn` | Phase 4 (optional IAM scoping) |

### Deploy

```bash
cd live/dev/03-knowledge-base
terraform init
terraform plan
terraform apply
```

> **⚠️ Important:** The `embedding_dimensions` value here **must exactly match** the `vector_dimensions` in Phase 2. A mismatch will cause runtime errors when Bedrock tries to store embeddings in the vector index.

---

## Phase 4 — Data Sources (`live/dev/04-data-sources/`)

### Architecture
Each data source instance is deployed in its **own directory** with its **own state file**. This means:
- Adding a new data source never touches existing ones
- Destroying one data source doesn't affect others
- Each can be independently managed and versioned

### S3 Data Source (`live/dev/04-data-sources/s3-docs`)

#### What It Creates
- **`aws_bedrockagent_data_source`** with type `S3` — Points to an existing S3 bucket containing your documents (PDFs, text, etc.)

#### Configurable Variables (`terraform.tfvars`)

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_profile` | string | `default` | AWS CLI profile name |
| `region` | string | `us-east-1` | AWS region |
| `environment` | string | `dev` | Environment name |
| `data_source_name` | string | `dev-s3-docs` | Name of the data source (visible in Bedrock console) |
| `s3_bucket_arn` | string | *required* | ARN of the S3 bucket containing documents (**bucket only, no trailing path**) |
| `s3_inclusion_prefixes` | list(string) | `[]` | Restrict ingestion to specific S3 prefixes (e.g., `["items/", "docs/"]`) |
| `chunking_strategy` | string | `FIXED_SIZE` | How documents are split: `FIXED_SIZE`, `HIERARCHICAL`, `SEMANTIC`, or `NONE` |
| `parsing_strategy` | string | `NONE` | How documents are parsed: `BEDROCK_DATA_AUTOMATION`, `BEDROCK_FOUNDATION_MODEL`, or `NONE` |
| `parsing_model_arn` | string | `null` | Model ARN (required only when `parsing_strategy = "BEDROCK_FOUNDATION_MODEL"`) |

#### Current Active Configuration

```hcl
aws_profile = "AJ-PHP-LZ"
region      = "us-east-1"
environment = "dev"

data_source_name      = "my-s3-docs"
s3_bucket_arn         = "arn:aws:s3:::aws-kb-test1-data-store-aj-20hph"
s3_inclusion_prefixes = ["items/"]
chunking_strategy     = "FIXED_SIZE"
```

#### Deploy

```bash
cd live/dev/04-data-sources/s3-docs
terraform init
terraform plan
terraform apply
```

#### After Deploying — Sync Your Data
After the data source is created, go to the **AWS Bedrock Console → Knowledge bases → Your KB → Data sources → Click Sync** to trigger the initial ingestion.

---

### Custom Data Source (`live/dev/04-data-sources/custom-api`)

#### What It Creates
- **`aws_bedrockagent_data_source`** with type `CUSTOM` — Data is pushed programmatically via the Bedrock Ingestion API (no S3 bucket needed)

#### Configurable Variables (`terraform.tfvars`)

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_profile` | string | `default` | AWS CLI profile name |
| `region` | string | `us-east-1` | AWS region |
| `environment` | string | `dev` | Environment name |
| `data_source_name` | string | `dev-custom-api` | Name of the data source |
| `chunking_strategy` | string | `FIXED_SIZE` | How documents are split |
| `parsing_strategy` | string | `NONE` | How documents are parsed |
| `parsing_model_arn` | string | `null` | Model ARN (for FM-based parsing) |

#### Deploy

```bash
cd live/dev/04-data-sources/custom-api
terraform init
terraform plan
terraform apply
```

---

### Adding a New Data Source Instance

To add another S3 data source (e.g., a second bucket):

1. **Copy** the `s3-docs` folder:
   ```bash
   cp -r live/dev/04-data-sources/s3-docs live/dev/04-data-sources/s3-reports
   ```
2. **Update** `backend.tf` — change the state key to a unique path:
   ```hcl
   key = "live/dev/04-data-sources/s3-reports/terraform.tfstate"
   ```
3. **Update** `terraform.tfvars` with the new bucket ARN and name
4. **Update** `live/dev/01-foundation/terraform.tfvars` — add the new bucket ARN to `s3_data_bucket_arns`, then re-apply foundation
5. **Deploy** the new data source:
   ```bash
   cd live/dev/04-data-sources/s3-reports
   terraform init && terraform apply
   ```

---

## Common Gotchas

| Issue | Cause | Fix |
|-------|-------|-----|
| `403 Forbidden: s3:ListBucket` on sync | IAM role missing S3 permissions | Add bucket ARN (+ `/*`) to `s3_data_bucket_arns` in Phase 1, re-apply |
| `bucketArn failed regex` on apply | S3 ARN includes a path (e.g., `/items/`) | Use only the bucket ARN, move the path to `s3_inclusion_prefixes` |
| `no such index` on KB creation | Vector index not created in the vector store | Ensure Phase 2 applied successfully with the index resource |
| `engine type is invalid` on KB creation | OpenSearch index uses nmslib instead of FAISS | Recreate the index with `engine = "faiss"` |
| State lock error | Previous apply crashed or was interrupted | Run `terraform force-unlock <LOCK-ID>` |
| Chunking/parsing change fails | These are immutable after data source creation | Destroy and recreate the data source |
| Dimension mismatch errors | Phase 2 `vector_dimensions` ≠ Phase 3 `embedding_dimensions` | Ensure both values match exactly |

---

## Further Documentation

| Document | Description |
|----------|-------------|
| [module-contracts.md](docs/module-contracts.md) | Full input/output schemas for every module |
| [data-source-architecture.md](docs/data-source-architecture.md) | Why data sources use isolated state files |
| [phase1.md](docs/phase1.md) | Foundation layer task tracker and verification |
| [phase2.md](docs/phase2.md) | Vector store task tracker and verification |
| [phase3.md](docs/phase3.md) | Knowledge base task tracker and verification |
| [phase4.md](docs/phase4.md) | Data source task tracker and verification |
