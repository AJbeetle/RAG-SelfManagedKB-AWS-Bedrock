# Bedrock Self-Managed Knowledge Base Terraform Repository

This repository provisions **Amazon Bedrock Self-Managed Knowledge Bases** via Terraform, specifically tailored for unstructured data RAG pipelines.

## Prerequisites
- **Terraform:** v1.5.0 or higher
- **AWS Provider:** v5.0.0 or higher
- **AWS Credentials:** Configured via standard AWS mechanisms (e.g., `~/.aws/credentials`, `AWS_ACCESS_KEY_ID`, SSO, etc.)

## Quick Start
To bootstrap a new environment, deploy in the following order:
1. **Foundation:** `cd live/dev/01-foundation` -> `terraform apply`
2. **Vector Store:** `cd live/dev/02-vector-store` -> `terraform apply`
3. **Knowledge Base:** `cd live/dev/03-knowledge-base` -> `terraform apply`
4. **Data Sources:** `cd live/dev/04-data-sources/<source-name>` -> `terraform apply`

For more detailed module inputs and outputs, please see [docs/module-contracts.md](docs/module-contracts.md).
