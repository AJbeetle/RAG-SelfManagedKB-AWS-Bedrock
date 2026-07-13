# OpenSearch Serverless Deployment Profile

OpenSearch Serverless uses both the AWS and OpenSearch providers, so this profile uses the staged roots under `live/dev` rather than duplicating their state and provider wiring.

Copy the four files in this directory to the matching staged roots as `terraform.tfvars`, replace the state bucket and source bucket values, and deploy in numeric order:

1. `live/dev/01-foundation`
2. `live/dev/02-vector-store`
3. `live/dev/03-knowledge-base`
4. `live/dev/04-data-sources/s3-docs`

Initialize every root with its `backend.s3.tfbackend` file as described in the repository README.
