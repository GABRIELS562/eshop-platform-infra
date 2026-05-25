variable "namespace_name" {
  description = "Name of the namespace"
  type        = string
}

variable "project_name" {
  description = "Project name for labeling"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "team" {
  description = "Team name"
  type        = string
  default     = "platform"
}

variable "description" {
  description = "Namespace description"
  type        = string
  default     = ""
}

variable "additional_labels" {
  description = "Additional labels to apply"
  type        = map(string)
  default     = {}
}

variable "additional_annotations" {
  description = "Additional annotations to apply"
  type        = map(string)
  default     = {}
}

variable "enable_resource_quota" {
  description = "Enable resource quota"
  type        = bool
  default     = true
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

variable "enable_limit_range" {
  description = "Enable limit range"
  type        = bool
  default     = true
}

variable "limit_range" {
  description = "Limit range configuration"
  type = object({
    default_cpu            = string
    default_memory         = string
    default_request_cpu    = string
    default_request_memory = string
    max_storage            = string
  })
  default = {
    default_cpu            = "200m"
    default_memory         = "256Mi"
    default_request_cpu    = "100m"
    default_request_memory = "128Mi"
    max_storage            = "10Gi"
  }
}
