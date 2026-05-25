# Development environment configuration
locals {
  environment = "dev"

  # Development-specific settings
  replica_count = 1

  # Resource limits (lower for dev)
  resource_quota = {
    requests_cpu    = "10"
    requests_memory = "20Gi"
    limits_cpu      = "20"
    limits_memory   = "40Gi"
    pods            = "50"
    services        = "25"
    secrets         = "50"
    configmaps      = "50"
    pvcs            = "10"
  }

  # Autoscaling (disabled for dev)
  autoscaling_enabled = false

  # ArgoCD sync (manual for dev)
  auto_sync_enabled = false
}
