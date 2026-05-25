# Production Environment - Main Configuration
# Deploys the complete eShop platform to production

terraform {
  required_version = ">= 1.5.0"
}

# Create namespace
module "namespace" {
  source = "../../modules/k3s-namespace"

  namespace_name        = var.namespace_name
  project_name          = var.project_name
  environment           = var.environment
  team                  = var.team
  description           = "eShopOnContainers Production Environment"
  enable_resource_quota = true
  resource_quota        = var.resource_quota
  enable_limit_range    = true
}

# Apply network policies
module "network_policies" {
  source = "../../modules/network-policies"

  namespace               = module.namespace.namespace_name
  project_name            = var.project_name
  environment             = var.environment
  team                    = var.team
  enable_default_deny     = true
  enable_monitoring_access = true
  enable_vault_access     = true
  vault_ip                = var.vault_ip
}

# Configure Vault secrets
module "vault_secrets" {
  source = "../../modules/vault-secrets"

  project_name           = var.project_name
  environment            = var.environment
  enable_secrets_engine  = false  # Already exists
  rabbitmq_host          = var.rabbitmq_host
  rabbitmq_user          = var.rabbitmq_user
  rabbitmq_pass          = var.rabbitmq_pass
  service_secrets        = var.service_secrets
  enable_kubernetes_auth = true
  bound_namespaces       = [module.namespace.namespace_name, "external-secrets"]
}

# Deploy ArgoCD applications for each service
module "argocd_applications" {
  source   = "../../modules/argocd-application"
  for_each = var.services

  application_name      = each.key
  argocd_project        = var.project_name
  environment           = var.environment
  team                  = var.team
  repo_url              = "https://github.com/${var.github_owner}/eshop-platform-infra"
  target_revision       = var.target_revision
  helm_path             = "helm-charts/${each.key}"
  destination_namespace = module.namespace.namespace_name
  enable_auto_sync      = var.auto_sync_enabled
  auto_prune            = var.auto_prune
  self_heal             = var.self_heal

  helm_values = yamlencode({
    replicaCount = each.value.replicas
    resources = {
      requests = {
        cpu    = each.value.cpu_request
        memory = each.value.memory_request
      }
      limits = {
        cpu    = each.value.cpu_limit
        memory = each.value.memory_limit
      }
    }
    autoscaling = {
      enabled     = var.autoscaling_enabled
      minReplicas = var.min_replicas
      maxReplicas = var.max_replicas
    }
  })
}

# Deploy infrastructure ArgoCD applications
module "infrastructure_apps" {
  source   = "../../modules/argocd-application"
  for_each = toset(["rabbitmq", "redis", "postgresql", "seq"])

  application_name      = each.key
  argocd_project        = var.project_name
  environment           = var.environment
  team                  = var.team
  repo_url              = "https://github.com/${var.github_owner}/eshop-platform-infra"
  target_revision       = var.target_revision
  helm_path             = "k8s/infrastructure/${each.key}"
  destination_namespace = module.namespace.namespace_name
  enable_auto_sync      = var.auto_sync_enabled
  auto_prune            = var.auto_prune
  self_heal             = var.self_heal
}
