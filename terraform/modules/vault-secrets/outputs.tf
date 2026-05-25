output "policy_name" {
  description = "Name of the Vault policy"
  value       = vault_policy.eshop.name
}

output "secret_paths" {
  description = "Paths to created secrets"
  value = concat(
    [vault_kv_secret_v2.global.path],
    [for k, v in vault_kv_secret_v2.service_secrets : v.path]
  )
}

output "auth_role_name" {
  description = "Kubernetes auth role name"
  value       = var.enable_kubernetes_auth ? vault_kubernetes_auth_backend_role.eshop[0].role_name : null
}
