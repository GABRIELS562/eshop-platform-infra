# K3s Namespace Module
# Creates namespace with resource quotas, limit ranges, and labels

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace_name

    labels = merge(
      {
        "app"                         = var.project_name
        "env"                         = var.environment
        "team"                        = var.team
        "managed-by"                  = "terraform"
        "kubernetes.io/metadata.name" = var.namespace_name
      },
      var.additional_labels
    )

    annotations = merge(
      {
        "description" = var.description
        "owner"       = var.team
      },
      var.additional_annotations
    )
  }
}

resource "kubernetes_resource_quota" "this" {
  count = var.enable_resource_quota ? 1 : 0

  metadata {
    name      = "${var.namespace_name}-resource-quota"
    namespace = kubernetes_namespace.this.metadata[0].name

    labels = {
      "app"        = var.project_name
      "env"        = var.environment
      "team"       = var.team
      "managed-by" = "terraform"
    }
  }

  spec {
    hard = {
      "requests.cpu"            = var.resource_quota.requests_cpu
      "requests.memory"         = var.resource_quota.requests_memory
      "limits.cpu"              = var.resource_quota.limits_cpu
      "limits.memory"           = var.resource_quota.limits_memory
      "pods"                    = var.resource_quota.pods
      "services"                = var.resource_quota.services
      "secrets"                 = var.resource_quota.secrets
      "configmaps"              = var.resource_quota.configmaps
      "persistentvolumeclaims"  = var.resource_quota.pvcs
    }
  }
}

resource "kubernetes_limit_range" "this" {
  count = var.enable_limit_range ? 1 : 0

  metadata {
    name      = "${var.namespace_name}-limit-range"
    namespace = kubernetes_namespace.this.metadata[0].name

    labels = {
      "app"        = var.project_name
      "env"        = var.environment
      "team"       = var.team
      "managed-by" = "terraform"
    }
  }

  spec {
    limit {
      type = "Container"

      default = {
        cpu    = var.limit_range.default_cpu
        memory = var.limit_range.default_memory
      }

      default_request = {
        cpu    = var.limit_range.default_request_cpu
        memory = var.limit_range.default_request_memory
      }
    }

    limit {
      type = "PersistentVolumeClaim"

      max = {
        storage = var.limit_range.max_storage
      }
    }
  }
}
