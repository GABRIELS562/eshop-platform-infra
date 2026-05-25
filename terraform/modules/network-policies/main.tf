# Network Policies Module
# Creates Kubernetes NetworkPolicies for zero-trust security

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
}

# Default deny all
resource "kubernetes_network_policy" "default_deny" {
  count = var.enable_default_deny ? 1 : 0

  metadata {
    name      = "default-deny-all"
    namespace = var.namespace

    labels = {
      "app"         = var.project_name
      "env"         = var.environment
      "team"        = var.team
      "policy-type" = "default"
      "managed-by"  = "terraform"
    }
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}

# Allow DNS
resource "kubernetes_network_policy" "allow_dns" {
  metadata {
    name      = "allow-dns"
    namespace = var.namespace

    labels = {
      "app"         = var.project_name
      "env"         = var.environment
      "team"        = var.team
      "policy-type" = "system"
      "managed-by"  = "terraform"
    }
  }

  spec {
    pod_selector {}
    policy_types = ["Egress"]

    egress {
      to {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = "kube-system"
          }
        }
      }

      ports {
        protocol = "UDP"
        port     = "53"
      }
      ports {
        protocol = "TCP"
        port     = "53"
      }
    }
  }
}

# Allow Prometheus scraping
resource "kubernetes_network_policy" "allow_monitoring" {
  count = var.enable_monitoring_access ? 1 : 0

  metadata {
    name      = "allow-prometheus-scraping"
    namespace = var.namespace

    labels = {
      "app"         = var.project_name
      "env"         = var.environment
      "team"        = var.team
      "policy-type" = "monitoring"
      "managed-by"  = "terraform"
    }
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress"]

    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = var.monitoring_namespace
          }
        }
      }

      ports {
        protocol = "TCP"
        port     = "80"
      }
      ports {
        protocol = "TCP"
        port     = "8080"
      }
      ports {
        protocol = "TCP"
        port     = "9090"
      }
    }
  }
}

# Allow Vault egress
resource "kubernetes_network_policy" "allow_vault" {
  count = var.enable_vault_access ? 1 : 0

  metadata {
    name      = "allow-egress-to-vault"
    namespace = var.namespace

    labels = {
      "app"         = var.project_name
      "env"         = var.environment
      "team"        = var.team
      "policy-type" = "secrets"
      "managed-by"  = "terraform"
    }
  }

  spec {
    pod_selector {}
    policy_types = ["Egress"]

    egress {
      to {
        ip_block {
          cidr = "${var.vault_ip}/32"
        }
      }

      ports {
        protocol = "TCP"
        port     = var.vault_port
      }
    }
  }
}

# Allow egress to infrastructure services
resource "kubernetes_network_policy" "allow_infrastructure" {
  for_each = var.infrastructure_services

  metadata {
    name      = "allow-egress-to-${each.key}"
    namespace = var.namespace

    labels = {
      "app"         = var.project_name
      "env"         = var.environment
      "team"        = var.team
      "policy-type" = "infrastructure"
      "managed-by"  = "terraform"
    }
  }

  spec {
    pod_selector {
      match_labels = {
        "needs-${each.key}" = "true"
      }
    }
    policy_types = ["Egress"]

    egress {
      to {
        pod_selector {
          match_labels = {
            "app" = each.key
          }
        }
      }

      ports {
        protocol = "TCP"
        port     = each.value.port
      }
    }
  }
}
