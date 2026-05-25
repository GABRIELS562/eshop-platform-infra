# Production environment configuration
locals {
  environment = "prod"

  # Production settings
  replica_count = 2

  # Resource limits (full capacity)
  resource_quota = {
    requests_cpu    = "20"
    requests_memory = "40Gi"
    limits_cpu      = "40"
    limits_memory   = "80Gi"
    pods            = "100"
    services        = "50"
    secrets         = "100"
    configmaps      = "100"
    pvcs            = "20"
  }

  # Autoscaling (full production config)
  autoscaling_enabled = true
  min_replicas        = 2
  max_replicas        = 5

  # ArgoCD sync (automated with self-heal)
  auto_sync_enabled = true
  self_heal_enabled = true
  auto_prune        = true
}
