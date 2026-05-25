variable "application_name" {
  description = "Name of the ArgoCD application"
  type        = string
}

variable "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
  type        = string
  default     = "argocd"
}

variable "argocd_project" {
  description = "ArgoCD project name"
  type        = string
  default     = "default"
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

variable "repo_url" {
  description = "Git repository URL"
  type        = string
}

variable "target_revision" {
  description = "Git revision (branch, tag, commit)"
  type        = string
  default     = "main"
}

variable "helm_path" {
  description = "Path to Helm chart in repository"
  type        = string
}

variable "value_files" {
  description = "List of Helm value files"
  type        = list(string)
  default     = ["values.yaml"]
}

variable "helm_values" {
  description = "Inline Helm values (YAML string)"
  type        = string
  default     = ""
}

variable "destination_server" {
  description = "Kubernetes API server URL"
  type        = string
  default     = "https://kubernetes.default.svc"
}

variable "destination_namespace" {
  description = "Target namespace for deployment"
  type        = string
}

variable "enable_auto_sync" {
  description = "Enable automated sync"
  type        = bool
  default     = true
}

variable "auto_prune" {
  description = "Enable automatic pruning"
  type        = bool
  default     = true
}

variable "self_heal" {
  description = "Enable self-healing"
  type        = bool
  default     = true
}

variable "sync_options" {
  description = "Sync options"
  type        = list(string)
  default     = ["CreateNamespace=true"]
}

variable "ignore_differences" {
  description = "Fields to ignore during diff"
  type = list(object({
    group        = string
    kind         = string
    jsonPointers = list(string)
  }))
  default = [
    {
      group        = "autoscaling"
      kind         = "HorizontalPodAutoscaler"
      jsonPointers = ["/spec/metrics"]
    }
  ]
}
