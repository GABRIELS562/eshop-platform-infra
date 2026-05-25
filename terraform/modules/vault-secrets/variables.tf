variable "project_name" {
  description = "Project name"
  type        = string
  default     = "eshop"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "secrets_path" {
  description = "Vault secrets engine path"
  type        = string
  default     = "secret"
}

variable "enable_secrets_engine" {
  description = "Enable/create the secrets engine"
  type        = bool
  default     = false
}

# RabbitMQ credentials
variable "rabbitmq_host" {
  description = "RabbitMQ host"
  type        = string
  default     = "rabbitmq.eshop.svc.cluster.local"
}

variable "rabbitmq_user" {
  description = "RabbitMQ username"
  type        = string
  default     = "[placeholder]"
}

variable "rabbitmq_pass" {
  description = "RabbitMQ password"
  type        = string
  sensitive   = true
  default     = "[placeholder]"
}

# Service-specific secrets
variable "service_secrets" {
  description = "Map of service names to their secrets"
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

# Kubernetes auth configuration
variable "enable_kubernetes_auth" {
  description = "Enable Kubernetes auth role"
  type        = bool
  default     = true
}

variable "kubernetes_auth_path" {
  description = "Kubernetes auth backend path"
  type        = string
  default     = "kubernetes"
}

variable "bound_service_accounts" {
  description = "Service accounts allowed to authenticate"
  type        = list(string)
  default     = ["external-secrets-sa", "default"]
}

variable "bound_namespaces" {
  description = "Namespaces allowed to authenticate"
  type        = list(string)
  default     = ["external-secrets", "eshop"]
}

variable "token_ttl" {
  description = "Token TTL in seconds"
  type        = number
  default     = 3600
}
