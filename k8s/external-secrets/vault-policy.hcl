# Vault policy for eShop Platform secrets access
# This policy grants read-only access to all secrets under the eshop path
# Policy name: eshop-policy

# Allow reading secret data from the eshop path
# This covers all service-specific secrets (basket-api, catalog-api, etc.)
path "secret/data/eshop/*" {
  capabilities = ["read", "list"]
}

# Allow listing and reading metadata for secrets
# Required for secret discovery and version information
path "secret/metadata/eshop/*" {
  capabilities = ["read", "list"]
}
