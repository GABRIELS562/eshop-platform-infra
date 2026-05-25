# Production Environment Outputs

output "namespace" {
  description = "Created namespace"
  value       = module.namespace.namespace_name
}

output "network_policies" {
  description = "Created network policies"
  value       = module.network_policies.policies_created
}

output "vault_policy" {
  description = "Vault policy name"
  value       = module.vault_secrets.policy_name
}

output "argocd_applications" {
  description = "ArgoCD applications created"
  value       = [for app in module.argocd_applications : app.application_name]
}

output "infrastructure_applications" {
  description = "Infrastructure ArgoCD applications"
  value       = [for app in module.infrastructure_apps : app.application_name]
}
