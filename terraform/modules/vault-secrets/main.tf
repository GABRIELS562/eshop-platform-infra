# Vault Secrets Module
# Creates Vault KV secrets and policies for eShop services

terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.23"
    }
  }
}

# Enable KV v2 secrets engine
resource "vault_mount" "kvv2" {
  count = var.enable_secrets_engine ? 1 : 0

  path        = var.secrets_path
  type        = "kv"
  description = "KV v2 secrets engine for ${var.project_name}"

  options = {
    version = "2"
  }
}

# Global secrets
resource "vault_kv_secret_v2" "global" {
  mount = var.enable_secrets_engine ? vault_mount.kvv2[0].path : var.secrets_path
  name  = "${var.project_name}/global"

  data_json = jsonencode({
    RABBITMQ_HOST = var.rabbitmq_host
    RABBITMQ_USER = var.rabbitmq_user
    RABBITMQ_PASS = var.rabbitmq_pass
  })

  custom_metadata {
    max_versions = 10
    data = {
      environment = var.environment
      managed_by  = "terraform"
    }
  }
}

# Service-specific secrets
resource "vault_kv_secret_v2" "service_secrets" {
  for_each = var.service_secrets

  mount = var.enable_secrets_engine ? vault_mount.kvv2[0].path : var.secrets_path
  name  = "${var.project_name}/${each.key}"

  data_json = jsonencode(each.value)

  custom_metadata {
    max_versions = 10
    data = {
      service     = each.key
      environment = var.environment
      managed_by  = "terraform"
    }
  }
}

# Vault policy for eShop
resource "vault_policy" "eshop" {
  name = "${var.project_name}-policy"

  policy = <<-EOT
    # eShop Platform Vault Policy
    # Managed by Terraform

    # Read access to all eshop secrets
    path "${var.secrets_path}/data/${var.project_name}/*" {
      capabilities = ["read", "list"]
    }

    path "${var.secrets_path}/metadata/${var.project_name}/*" {
      capabilities = ["read", "list"]
    }
  EOT
}

# Kubernetes auth role for External Secrets Operator
resource "vault_kubernetes_auth_backend_role" "eshop" {
  count = var.enable_kubernetes_auth ? 1 : 0

  backend                          = var.kubernetes_auth_path
  role_name                        = "${var.project_name}-role"
  bound_service_account_names      = var.bound_service_accounts
  bound_service_account_namespaces = var.bound_namespaces
  token_ttl                        = var.token_ttl
  token_policies                   = [vault_policy.eshop.name]
}
