# Root Terragrunt configuration
# Defines common settings for all environments

locals {
  # Parse the environment from the path
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl", "env.hcl"))

  environment  = local.env_vars.locals.environment
  project_name = "eshop"
  team         = "platform"

  # Server configuration
  k3s_host     = "100.89.26.128"
  vault_host   = "100.103.13.92"

  # GitHub configuration
  github_owner = "GABRIELS562"
  github_repo  = "eshop-platform-infra"
}

# Generate provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "kubernetes" {
      config_path = var.kubeconfig_path
    }

    provider "helm" {
      kubernetes {
        config_path = var.kubeconfig_path
      }
    }

    provider "vault" {
      address = "http://${local.vault_host}:8200"
      token   = var.vault_token
    }

    provider "github" {
      owner = "${local.github_owner}"
      token = var.github_token
    }
  EOF
}

# Remote state configuration using local backend for K3s
# In production, use S3/GCS/Azure Blob with state locking
remote_state {
  backend = "local"
  config = {
    path = "${get_parent_terragrunt_dir()}/.terraform-state/${local.environment}/terraform.tfstate"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Common inputs for all modules
inputs = {
  environment    = local.environment
  project_name   = local.project_name
  team           = local.team

  kubernetes_host = "https://${local.k3s_host}:6443"
  vault_address   = "http://${local.vault_host}:8200"

  github_owner = local.github_owner
}
