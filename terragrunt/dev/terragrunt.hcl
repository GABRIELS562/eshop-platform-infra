# Development environment Terragrunt configuration

include "root" {
  path = find_in_parent_folders()
}

locals {
  env_vars = read_terragrunt_config("env.hcl")
}

terraform {
  source = "${get_parent_terragrunt_dir()}/../terraform/environments/dev"
}

inputs = {
  environment = local.env_vars.locals.environment

  # Namespace configuration
  namespace_name = "eshop-dev"

  # Resource quota (lower for dev)
  resource_quota = local.env_vars.locals.resource_quota

  # Service replicas
  replica_count = local.env_vars.locals.replica_count

  # ArgoCD configuration
  target_revision   = "develop"
  auto_sync_enabled = local.env_vars.locals.autoscaling_enabled

  # Autoscaling
  autoscaling_enabled = local.env_vars.locals.autoscaling_enabled
}
