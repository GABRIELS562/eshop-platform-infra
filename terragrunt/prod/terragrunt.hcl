# Production environment Terragrunt configuration

include "root" {
  path = find_in_parent_folders()
}

locals {
  env_vars = read_terragrunt_config("env.hcl")
}

terraform {
  source = "${get_parent_terragrunt_dir()}/../terraform/environments/prod"
}

inputs = {
  environment = local.env_vars.locals.environment

  # Namespace configuration
  namespace_name = "eshop"

  # Resource quota (full production)
  resource_quota = local.env_vars.locals.resource_quota

  # Service replicas
  replica_count = local.env_vars.locals.replica_count

  # ArgoCD configuration
  target_revision   = "main"
  auto_sync_enabled = local.env_vars.locals.auto_sync_enabled
  self_heal         = local.env_vars.locals.self_heal_enabled
  auto_prune        = local.env_vars.locals.auto_prune

  # Autoscaling
  autoscaling_enabled = local.env_vars.locals.autoscaling_enabled
  min_replicas        = local.env_vars.locals.min_replicas
  max_replicas        = local.env_vars.locals.max_replicas
}
