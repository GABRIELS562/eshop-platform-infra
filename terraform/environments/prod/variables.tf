# Production Environment Variables

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "eshop"
}

variable "team" {
  description = "Team name"
  type        = string
  default     = "platform"
}

variable "namespace_name" {
  description = "Kubernetes namespace name"
  type        = string
  default     = "eshop"
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig"
  type        = string
  default     = "/etc/rancher/k3s/k3s.yaml"
}

variable "vault_ip" {
  description = "Vault server IP"
  type        = string
  default     = "100.103.13.92"
}

variable "vault_token" {
  description = "Vault token"
  type        = string
  sensitive   = true
  default     = ""
}

variable "github_owner" {
  description = "GitHub owner"
  type        = string
  default     = "GABRIELS562"
}

variable "github_token" {
  description = "GitHub token"
  type        = string
  sensitive   = true
  default     = ""
}

variable "resource_quota" {
  description = "Resource quota configuration"
  type = object({
    requests_cpu    = string
    requests_memory = string
    limits_cpu      = string
    limits_memory   = string
    pods            = string
    services        = string
    secrets         = string
    configmaps      = string
    pvcs            = string
  })
  default = {
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
}

variable "services" {
  description = "Map of services"
  type = map(object({
    replicas       = number
    cpu_request    = string
    memory_request = string
    cpu_limit      = string
    memory_limit   = string
    needs_database = bool
    needs_redis    = bool
    needs_rabbitmq = bool
  }))
}

variable "target_revision" {
  description = "Git revision for ArgoCD"
  type        = string
  default     = "main"
}

variable "auto_sync_enabled" {
  description = "Enable ArgoCD auto sync"
  type        = bool
  default     = true
}

variable "auto_prune" {
  description = "Enable ArgoCD auto prune"
  type        = bool
  default     = true
}

variable "self_heal" {
  description = "Enable ArgoCD self heal"
  type        = bool
  default     = true
}

variable "autoscaling_enabled" {
  description = "Enable HPA"
  type        = bool
  default     = true
}

variable "min_replicas" {
  description = "Minimum replicas for HPA"
  type        = number
  default     = 2
}

variable "max_replicas" {
  description = "Maximum replicas for HPA"
  type        = number
  default     = 5
}

variable "replica_count" {
  description = "Default replica count"
  type        = number
  default     = 2
}

variable "rabbitmq_host" {
  description = "RabbitMQ host"
  type        = string
  default     = "rabbitmq.eshop.svc.cluster.local"
}

variable "rabbitmq_user" {
  description = "RabbitMQ user"
  type        = string
  default     = "[placeholder]"
}

variable "rabbitmq_pass" {
  description = "RabbitMQ password"
  type        = string
  sensitive   = true
  default     = "[placeholder]"
}

variable "service_secrets" {
  description = "Service-specific secrets"
  type        = map(map(string))
  default = {
    basket-api = {
      REDIS_CONNECTION = "[placeholder]"
      IDENTITY_URL     = "http://identity-api.eshop.svc.cluster.local"
    }
    catalog-api = {
      DB_CONNECTION = "[placeholder]"
    }
    ordering-api = {
      DB_CONNECTION = "[placeholder]"
      IDENTITY_URL  = "http://identity-api.eshop.svc.cluster.local"
    }
    identity-api = {
      DB_CONNECTION        = "[placeholder]"
      CERTIFICATE_PASSWORD = "[placeholder]"
    }
    payment-api = {
      PAYMENT_GATEWAY_KEY = "[placeholder]"
    }
  }
}
