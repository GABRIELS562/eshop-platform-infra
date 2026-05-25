# ArgoCD Application Module
# Creates ArgoCD Application resources for GitOps deployment

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
}

resource "kubernetes_manifest" "argocd_application" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name      = var.application_name
      namespace = var.argocd_namespace

      labels = {
        "app"        = var.application_name
        "env"        = var.environment
        "team"       = var.team
        "managed-by" = "terraform"
      }
    }

    spec = {
      project = var.argocd_project

      source = {
        repoURL        = var.repo_url
        targetRevision = var.target_revision
        path           = var.helm_path

        helm = {
          valueFiles = var.value_files
          values     = var.helm_values
        }
      }

      destination = {
        server    = var.destination_server
        namespace = var.destination_namespace
      }

      syncPolicy = var.enable_auto_sync ? {
        automated = {
          prune    = var.auto_prune
          selfHeal = var.self_heal
        }
        syncOptions = var.sync_options
      } : null

      ignoreDifferences = var.ignore_differences
    }
  }
}
