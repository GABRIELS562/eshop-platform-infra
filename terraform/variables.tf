# Global Variables
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "eshop"
}

variable "team" {
  description = "Team name for resource tagging"
  type        = string
  default     = "platform"
}

# Kubernetes Configuration
variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "/etc/rancher/k3s/k3s.yaml"
}

variable "kubernetes_host" {
  description = "Kubernetes API server host"
  type        = string
  default     = "https://100.89.26.128:6443"
}

# Vault Configuration
variable "vault_address" {
  description = "Vault server address"
  type        = string
  default     = "http://100.103.13.92:8200"
}

variable "vault_token" {
  description = "Vault token for authentication"
  type        = string
  sensitive   = true
  default     = ""
}

# Service Configuration
variable "services" {
  description = "Map of services to deploy"
  type = map(object({
    replicas        = number
    cpu_request     = string
    memory_request  = string
    cpu_limit       = string
    memory_limit    = string
    needs_database  = bool
    needs_redis     = bool
    needs_rabbitmq  = bool
  }))
  default = {
    basket-api = {
      replicas       = 2
      cpu_request    = "100m"
      memory_request = "128Mi"
      cpu_limit      = "200m"
      memory_limit   = "256Mi"
      needs_database = false
      needs_redis    = true
      needs_rabbitmq = true
    }
    catalog-api = {
      replicas       = 2
      cpu_request    = "100m"
      memory_request = "128Mi"
      cpu_limit      = "200m"
      memory_limit   = "256Mi"
      needs_database = true
      needs_redis    = false
      needs_rabbitmq = true
    }
    ordering-api = {
      replicas       = 2
      cpu_request    = "100m"
      memory_request = "128Mi"
      cpu_limit      = "200m"
      memory_limit   = "256Mi"
      needs_database = true
      needs_redis    = false
      needs_rabbitmq = true
    }
    identity-api = {
      replicas       = 2
      cpu_request    = "100m"
      memory_request = "128Mi"
      cpu_limit      = "200m"
      memory_limit   = "256Mi"
      needs_database = true
      needs_redis    = false
      needs_rabbitmq = false
    }
    payment-api = {
      replicas       = 2
      cpu_request    = "100m"
      memory_request = "128Mi"
      cpu_limit      = "200m"
      memory_limit   = "256Mi"
      needs_database = false
      needs_redis    = false
      needs_rabbitmq = true
    }
    webhook-api = {
      replicas       = 2
      cpu_request    = "100m"
      memory_request = "128Mi"
      cpu_limit      = "200m"
      memory_limit   = "256Mi"
      needs_database = false
      needs_redis    = false
      needs_rabbitmq = true
    }
    web-spa = {
      replicas       = 2
      cpu_request    = "50m"
      memory_request = "64Mi"
      cpu_limit      = "100m"
      memory_limit   = "128Mi"
      needs_database = false
      needs_redis    = false
      needs_rabbitmq = false
    }
    mobile-bff = {
      replicas       = 2
      cpu_request    = "100m"
      memory_request = "128Mi"
      cpu_limit      = "200m"
      memory_limit   = "256Mi"
      needs_database = false
      needs_redis    = false
      needs_rabbitmq = false
    }
    ordering-signalr = {
      replicas       = 2
      cpu_request    = "100m"
      memory_request = "128Mi"
      cpu_limit      = "200m"
      memory_limit   = "256Mi"
      needs_database = false
      needs_redis    = true
      needs_rabbitmq = true
    }
    api-gateway = {
      replicas       = 2
      cpu_request    = "100m"
      memory_request = "128Mi"
      cpu_limit      = "200m"
      memory_limit   = "256Mi"
      needs_database = false
      needs_redis    = false
      needs_rabbitmq = false
    }
  }
}

# Domain Configuration
variable "domain" {
  description = "Base domain for services"
  type        = string
  default     = "jagdevops.co.za"
}

# GitHub Configuration
variable "github_owner" {
  description = "GitHub organization/owner"
  type        = string
  default     = "GABRIELS562"
}

variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
  default     = ""
}
