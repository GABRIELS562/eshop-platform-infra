output "application_name" {
  description = "Name of the ArgoCD application"
  value       = var.application_name
}

output "destination_namespace" {
  description = "Target namespace"
  value       = var.destination_namespace
}
