# Staging environment Terragrunt configuration

include "root" {
  path = find_in_parent_folders()
}

locals {
  env_vars = read_terragrunt_config("env.hcl")
}

terraform {
  source = "${get_parent_terragrunt_dir()}/../terraform/environments/staging"
}

inputs = {
  environment = local.env_vars.locals.environment

  # Namespace configuration
  namespace_name = "eshop-staging"

  # Resource quota
  resource_quota = local.env_vars.locals.resource_quota

  # Service replicas
  replica_count = local.env_vars.locals.replica_count

  # ArgoCD configuration
  target_revision   = "develop"
  auto_sync_enabled = local.env_vars.locals.auto_sync_enabled

  # Autoscaling
  autoscaling_enabled = local.env_vars.locals.autoscaling_enabled
  min_replicas        = local.env_vars.locals.min_replicas
  max_replicas        = local.env_vars.locals.max_replicas
}
