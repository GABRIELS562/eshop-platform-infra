variable "namespace" {
  description = "Namespace to apply policies"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "team" {
  description = "Team name"
  type        = string
  default     = "platform"
}

variable "enable_default_deny" {
  description = "Enable default deny all policy"
  type        = bool
  default     = true
}

variable "enable_monitoring_access" {
  description = "Enable monitoring namespace access"
  type        = bool
  default     = true
}

variable "monitoring_namespace" {
  description = "Monitoring namespace name"
  type        = string
  default     = "monitoring"
}

variable "enable_vault_access" {
  description = "Enable Vault egress"
  type        = bool
  default     = true
}

variable "vault_ip" {
  description = "Vault server IP"
  type        = string
  default     = "100.103.13.92"
}

variable "vault_port" {
  description = "Vault server port"
  type        = string
  default     = "8200"
}

variable "infrastructure_services" {
  description = "Map of infrastructure services and their ports"
  type = map(object({
    port = string
  }))
  default = {
    postgresql = { port = "5432" }
    redis      = { port = "6379" }
    rabbitmq   = { port = "5672" }
  }
}
