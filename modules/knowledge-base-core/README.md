# Knowledge Base Core Module

This module provisions the core `aws_bedrockagent_knowledge_base` resource.

It wires the chosen embedding model with the storage configuration outputted by Phase 2.
This forms the "brain" of the RAG system, but requires Phase 4 to attach actual data sources to it.

## Inputs
See `variables.tf`

## Outputs
See `outputs.tf`
