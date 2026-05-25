#!/bin/bash
#
# Vault Setup Script for eShop Platform
# This script configures Vault with the necessary secrets, policies, and authentication
# for the External Secrets Operator to sync secrets to Kubernetes.
#
# Prerequisites:
#   - Vault CLI installed and configured
#   - VAULT_ADDR environment variable set
#   - VAULT_TOKEN environment variable set with admin privileges
#   - Kubernetes cluster with External Secrets Operator installed
#
# Usage:
#   export VAULT_ADDR="http://100.103.13.92:8200"
#   export VAULT_TOKEN="<root-or-admin-token>"
#   ./vault-setup.sh
#

set -euo pipefail

# Configuration
VAULT_ADDR="${VAULT_ADDR:-http://100.103.13.92:8200}"
KUBERNETES_HOST="${KUBERNETES_HOST:-https://kubernetes.default.svc}"
SECRETS_PATH="secret"
ESHOP_PATH="eshop"
POLICY_NAME="eshop-policy"
ROLE_NAME="eshop-role"
SERVICE_ACCOUNT="external-secrets-sa"
SERVICE_ACCOUNT_NAMESPACE="external-secrets"
BOUND_NAMESPACES="eshop,external-secrets"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_vault_connection() {
    log_info "Checking Vault connection..."
    if ! vault status > /dev/null 2>&1; then
        log_error "Cannot connect to Vault at ${VAULT_ADDR}"
        log_error "Please ensure VAULT_ADDR and VAULT_TOKEN are set correctly"
        exit 1
    fi
    log_info "Vault connection successful"
}

enable_secrets_engine() {
    log_info "Enabling KV v2 secrets engine at path '${SECRETS_PATH}'..."

    # Check if already enabled
    if vault secrets list | grep -q "^${SECRETS_PATH}/"; then
        log_warn "Secrets engine already enabled at '${SECRETS_PATH}'"
    else
        vault secrets enable -path="${SECRETS_PATH}" -version=2 kv
        log_info "KV v2 secrets engine enabled successfully"
    fi
}

create_secrets() {
    log_info "Creating secrets at path '${SECRETS_PATH}/${ESHOP_PATH}'..."

    # Global secrets (RabbitMQ)
    log_info "Creating global secrets..."
    vault kv put "${SECRETS_PATH}/${ESHOP_PATH}/global" \
        RABBITMQ_HOST="[PLACEHOLDER_RABBITMQ_HOST]" \
        RABBITMQ_USER="[PLACEHOLDER_RABBITMQ_USER]" \
        RABBITMQ_PASS="[PLACEHOLDER_RABBITMQ_PASS]"

    # Basket API secrets
    log_info "Creating basket-api secrets..."
    vault kv put "${SECRETS_PATH}/${ESHOP_PATH}/basket-api" \
        REDIS_CONNECTION="[PLACEHOLDER_REDIS_CONNECTION]" \
        IDENTITY_URL="[PLACEHOLDER_IDENTITY_URL]"

    # Catalog API secrets
    log_info "Creating catalog-api secrets..."
    vault kv put "${SECRETS_PATH}/${ESHOP_PATH}/catalog-api" \
        DB_CONNECTION="[PLACEHOLDER_CATALOG_DB_CONNECTION]"

    # Ordering API secrets
    log_info "Creating ordering-api secrets..."
    vault kv put "${SECRETS_PATH}/${ESHOP_PATH}/ordering-api" \
        DB_CONNECTION="[PLACEHOLDER_ORDERING_DB_CONNECTION]" \
        IDENTITY_URL="[PLACEHOLDER_IDENTITY_URL]"

    # Identity API secrets
    log_info "Creating identity-api secrets..."
    vault kv put "${SECRETS_PATH}/${ESHOP_PATH}/identity-api" \
        DB_CONNECTION="[PLACEHOLDER_IDENTITY_DB_CONNECTION]" \
        CERTIFICATE_PASSWORD="[PLACEHOLDER_CERTIFICATE_PASSWORD]"

    # Payment API secrets
    log_info "Creating payment-api secrets..."
    vault kv put "${SECRETS_PATH}/${ESHOP_PATH}/payment-api" \
        PAYMENT_GATEWAY_KEY="[PLACEHOLDER_PAYMENT_GATEWAY_KEY]"

    log_info "All secrets created successfully"
}

create_policy() {
    log_info "Creating Vault policy '${POLICY_NAME}'..."

    # Get the directory where this script is located
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    POLICY_FILE="${SCRIPT_DIR}/vault-policy.hcl"

    if [[ -f "${POLICY_FILE}" ]]; then
        vault policy write "${POLICY_NAME}" "${POLICY_FILE}"
        log_info "Policy created from file: ${POLICY_FILE}"
    else
        # Inline policy if file doesn't exist
        vault policy write "${POLICY_NAME}" - <<EOF
path "secret/data/eshop/*" {
  capabilities = ["read", "list"]
}
path "secret/metadata/eshop/*" {
  capabilities = ["read", "list"]
}
EOF
        log_info "Policy created inline"
    fi
}

enable_kubernetes_auth() {
    log_info "Enabling Kubernetes authentication method..."

    # Check if already enabled
    if vault auth list | grep -q "^kubernetes/"; then
        log_warn "Kubernetes auth method already enabled"
    else
        vault auth enable kubernetes
        log_info "Kubernetes auth method enabled successfully"
    fi
}

configure_kubernetes_auth() {
    log_info "Configuring Kubernetes authentication..."

    # Get Kubernetes CA certificate and token
    # These should be obtained from the Kubernetes cluster
    if [[ -f "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt" ]]; then
        # Running inside Kubernetes
        SA_CA_CRT=$(cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt)
        SA_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)

        vault write auth/kubernetes/config \
            kubernetes_host="${KUBERNETES_HOST}" \
            kubernetes_ca_cert="${SA_CA_CRT}" \
            token_reviewer_jwt="${SA_TOKEN}"
    else
        # Running outside Kubernetes - provide instructions
        log_warn "Running outside Kubernetes cluster"
        log_warn "Please configure Kubernetes auth manually with:"
        log_warn "  vault write auth/kubernetes/config \\"
        log_warn "    kubernetes_host=\"${KUBERNETES_HOST}\" \\"
        log_warn "    kubernetes_ca_cert=@/path/to/ca.crt \\"
        log_warn "    token_reviewer_jwt=\"\$(kubectl get secret -n external-secrets <sa-token-secret> -o jsonpath='{.data.token}' | base64 -d)\""

        # Try to configure using kubectl if available
        if command -v kubectl &> /dev/null; then
            log_info "Attempting to configure using kubectl..."

            # Get the Kubernetes CA certificate
            K8S_CA_CRT=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d 2>/dev/null || echo "")

            if [[ -n "${K8S_CA_CRT}" ]]; then
                # Get the current context's cluster server
                K8S_HOST=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[0].cluster.server}')

                vault write auth/kubernetes/config \
                    kubernetes_host="${K8S_HOST}" \
                    kubernetes_ca_cert="${K8S_CA_CRT}" \
                    disable_local_ca_jwt=true

                log_info "Kubernetes auth configured using kubectl context"
            else
                log_warn "Could not retrieve Kubernetes CA certificate"
            fi
        fi
    fi
}

create_kubernetes_role() {
    log_info "Creating Kubernetes role '${ROLE_NAME}'..."

    vault write "auth/kubernetes/role/${ROLE_NAME}" \
        bound_service_account_names="${SERVICE_ACCOUNT}" \
        bound_service_account_namespaces="${SERVICE_ACCOUNT_NAMESPACE}" \
        policies="${POLICY_NAME}" \
        ttl="1h" \
        max_ttl="24h"

    log_info "Kubernetes role created successfully"
}

verify_setup() {
    log_info "Verifying setup..."

    # Verify secrets exist
    log_info "Verifying secrets..."
    vault kv get "${SECRETS_PATH}/${ESHOP_PATH}/global" > /dev/null
    vault kv get "${SECRETS_PATH}/${ESHOP_PATH}/basket-api" > /dev/null
    vault kv get "${SECRETS_PATH}/${ESHOP_PATH}/catalog-api" > /dev/null
    vault kv get "${SECRETS_PATH}/${ESHOP_PATH}/ordering-api" > /dev/null
    vault kv get "${SECRETS_PATH}/${ESHOP_PATH}/identity-api" > /dev/null
    vault kv get "${SECRETS_PATH}/${ESHOP_PATH}/payment-api" > /dev/null
    log_info "All secrets verified"

    # Verify policy exists
    log_info "Verifying policy..."
    vault policy read "${POLICY_NAME}" > /dev/null
    log_info "Policy verified"

    # Verify Kubernetes auth role exists
    log_info "Verifying Kubernetes role..."
    vault read "auth/kubernetes/role/${ROLE_NAME}" > /dev/null
    log_info "Kubernetes role verified"

    log_info "Setup verification complete"
}

print_summary() {
    echo ""
    echo "=========================================="
    echo "  Vault Setup Complete for eShop Platform"
    echo "=========================================="
    echo ""
    echo "Secrets created:"
    echo "  - ${SECRETS_PATH}/${ESHOP_PATH}/global"
    echo "  - ${SECRETS_PATH}/${ESHOP_PATH}/basket-api"
    echo "  - ${SECRETS_PATH}/${ESHOP_PATH}/catalog-api"
    echo "  - ${SECRETS_PATH}/${ESHOP_PATH}/ordering-api"
    echo "  - ${SECRETS_PATH}/${ESHOP_PATH}/identity-api"
    echo "  - ${SECRETS_PATH}/${ESHOP_PATH}/payment-api"
    echo ""
    echo "Policy created: ${POLICY_NAME}"
    echo "Kubernetes role created: ${ROLE_NAME}"
    echo ""
    echo "IMPORTANT: Replace placeholder values with actual secrets:"
    echo "  vault kv put ${SECRETS_PATH}/${ESHOP_PATH}/global \\"
    echo "    RABBITMQ_HOST=\"rabbitmq.eshop.svc.cluster.local\" \\"
    echo "    RABBITMQ_USER=\"eshop\" \\"
    echo "    RABBITMQ_PASS=\"<actual-password>\""
    echo ""
    echo "Next steps:"
    echo "  1. Replace all [PLACEHOLDER_*] values with actual secrets"
    echo "  2. Apply the External Secrets manifests to Kubernetes:"
    echo "     kubectl apply -f cluster-secret-store.yaml"
    echo "     kubectl apply -f *-secrets.yaml"
    echo "  3. Verify External Secrets are syncing:"
    echo "     kubectl get externalsecrets -n eshop"
    echo ""
}

# Main execution
main() {
    echo ""
    echo "=========================================="
    echo "  Vault Setup for eShop Platform"
    echo "=========================================="
    echo ""

    check_vault_connection
    enable_secrets_engine
    create_secrets
    create_policy
    enable_kubernetes_auth
    configure_kubernetes_auth
    create_kubernetes_role
    verify_setup
    print_summary
}

# Run main function
main "$@"
