locals {
  standby_replicas = var.enable_standby_replicas ? "ENABLED" : "DISABLED"
}

resource "aws_opensearchserverless_security_policy" "encryption" {
  name        = "${var.collection_name}-encrypt"
  type        = "encryption"
  description = "Encryption policy for ${var.collection_name}"
  
  policy = jsonencode({
    Rules = [
      {
        Resource = ["collection/${var.collection_name}"]
        ResourceType = "collection"
      }
    ]
    AWSOwnedKey = var.kms_key_arn == null ? true : false
    KmsARN      = var.kms_key_arn
  })
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

resource "aws_opensearchserverless_access_policy" "data_access" {
  name        = "${var.collection_name}-access"
  type        = "data"
  description = "Data access policy for ${var.collection_name}"
  
  policy = jsonencode([
    {
      Description = "Access for Bedrock KB Role"
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
      Principal = [var.role_arn]
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
