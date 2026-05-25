# Staging environment configuration
locals {
  environment = "staging"

  # Staging settings (similar to prod but smaller)
  replica_count = 2

  # Resource limits
  resource_quota = {
    requests_cpu    = "15"
    requests_memory = "30Gi"
    limits_cpu      = "30"
    limits_memory   = "60Gi"
    pods            = "75"
    services        = "40"
    secrets         = "75"
    configmaps      = "75"
    pvcs            = "15"
  }

  # Autoscaling (enabled with lower limits)
  autoscaling_enabled = true
  min_replicas        = 1
  max_replicas        = 3

  # ArgoCD sync (automated)
  auto_sync_enabled = true
}
