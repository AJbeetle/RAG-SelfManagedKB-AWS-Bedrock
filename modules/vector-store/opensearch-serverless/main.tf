terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.54.0, < 7.0.0"
    }
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "~> 2.2"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.14"
    }
  }
}

locals {
  standby_replicas = var.enable_standby_replicas ? "ENABLED" : "DISABLED"
}

resource "aws_opensearchserverless_security_policy" "encryption" {
  name        = "${var.collection_name}-encrypt"
  type        = "encryption"
  description = "Encryption policy for ${var.collection_name}"

  policy = jsonencode(merge({
    Rules = [
      {
        Resource     = ["collection/${var.collection_name}"]
        ResourceType = "collection"
      }
    ]
    }, var.kms_key_arn == null ? {
    AWSOwnedKey = true
    } : {
    AWSOwnedKey = false
    KmsARN      = var.kms_key_arn
  }))
}

resource "aws_opensearchserverless_security_policy" "network" {
  name        = "${var.collection_name}-net"
  type        = "network"
  description = "Network policy for ${var.collection_name}"

  policy = jsonencode([
    {
      Description = "Public access for Bedrock"
      Rules = [
        {
          ResourceType = "collection"
          Resource     = ["collection/${var.collection_name}"]
        },
        {
          ResourceType = "dashboard"
          Resource     = ["collection/${var.collection_name}"]
        }
      ]
      AllowFromPublic = true
    }
  ])
}

data "aws_caller_identity" "current" {}

resource "aws_opensearchserverless_access_policy" "data_access" {
  name        = "${var.collection_name}-access"
  type        = "data"
  description = "Data access policy for ${var.collection_name}"

  policy = jsonencode([
    {
      Description = "Access for Bedrock KB Role and Terraform Caller"
      Rules = [
        {
          ResourceType = "collection"
          Resource     = ["collection/${var.collection_name}"]
          Permission   = ["aoss:*"]
        },
        {
          ResourceType = "index"
          Resource     = ["index/${var.collection_name}/*"]
          Permission   = ["aoss:*"]
        }
      ]
      Principal = [
        var.role_arn,
        data.aws_caller_identity.current.arn
      ]
    }
  ])
}

resource "aws_opensearchserverless_collection" "this" {
  name             = var.collection_name
  description      = var.collection_description
  type             = "VECTORSEARCH"
  standby_replicas = local.standby_replicas

  tags = var.tags

  depends_on = [
    aws_opensearchserverless_security_policy.encryption,
    aws_opensearchserverless_security_policy.network
  ]
}

resource "time_sleep" "wait_for_collection" {
  create_duration = "30s"
  depends_on      = [aws_opensearchserverless_collection.this, aws_opensearchserverless_access_policy.data_access]
}

resource "opensearch_index" "vector_index" {
  name = var.vector_index_name

  index_knn = true

  mappings = jsonencode({
    properties = {
      (var.vector_field_name) = {
        type      = "knn_vector"
        dimension = var.vector_dimensions

        method = {
          name       = "hnsw"
          engine     = "faiss" # "nmslib" not supported by AWS bedrock KB
          space_type = "cosinesimil"
        }
      }

      (var.text_field_name) = {
        type = "text"
      }

      (var.metadata_field_name) = {
        type  = "text"
        index = false
      }
    }
  })

  depends_on = [time_sleep.wait_for_collection]
}
