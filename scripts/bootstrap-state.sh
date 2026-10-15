#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Bootstrap Azure Storage for Terraform state with Entra ID (Azure AD) auth
#
# This script:
#   1. Creates a resource group and storage account for Terraform state
#   2. Disables shared-key access (Entra ID only), enables blob versioning and
#      soft delete so state files can be recovered
#   3. Creates the state container through the control plane
#   4. Assigns "Storage Blob Data Contributor" to the signed-in principal
#
# Prerequisites:
#   - Azure CLI >= 2.50, logged in (`az login`)
#   - Contributor + User Access Administrator (or Owner) on the subscription
#
# Works on Linux and macOS.
#
# Usage:
#   ./scripts/bootstrap-state.sh                          # defaults
#   ./scripts/bootstrap-state.sh -l northeurope           # override location
#   ./scripts/bootstrap-state.sh -g my-rg -s mystorage01  # override names
###############################################################################

# ── Defaults (override via flags) ───────────────────────────────────────────
RESOURCE_GROUP="rg-terraform-state"
LOCATION="westeurope"
STORAGE_ACCOUNT=""          # auto-generated if empty
CONTAINER_NAME="tfstate"
TAGS=("purpose=terraform-state" "managed-by=bootstrap-script")

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -g  Resource group name         (default: $RESOURCE_GROUP)
  -l  Azure region / location     (default: $LOCATION)
  -s  Storage account name        (default: auto-generated from subscription ID)
  -c  Blob container name         (default: $CONTAINER_NAME)
  -h  Show this help
EOF
  exit 0
}

while getopts "g:l:s:c:h" opt; do
  case $opt in
    g) RESOURCE_GROUP="$OPTARG" ;;
    l) LOCATION="$OPTARG" ;;
    s) STORAGE_ACCOUNT="$OPTARG" ;;
    c) CONTAINER_NAME="$OPTARG" ;;
    *) usage ;;
  esac
done

# ── Helpers ─────────────────────────────────────────────────────────────────
info()  { printf "\033[1;34m▶ %s\033[0m\n" "$*"; }
ok()    { printf "\033[1;32m✔ %s\033[0m\n" "$*"; }
warn()  { printf "\033[1;33m⚠ %s\033[0m\n" "$*"; }
fail()  { printf "\033[1;31m✖ %s\033[0m\n" "$*" >&2; exit 1; }

# Portable short hash (md5sum on Linux, md5 on macOS, shasum as fallback).
short_hash() {
  if command -v md5sum >/dev/null 2>&1; then
    printf '%s' "$1" | md5sum | cut -c1-8
  elif command -v md5 >/dev/null 2>&1; then
    printf '%s' "$1" | md5 -q | cut -c1-8
  else
    printf '%s' "$1" | shasum | cut -c1-8
  fi
}

# ── Pre-flight checks ──────────────────────────────────────────────────────
command -v az >/dev/null 2>&1 || fail "Azure CLI (az) is not installed."
az account show >/dev/null 2>&1 || fail "Not logged in. Run 'az login' first."

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
info "Active subscription: $SUBSCRIPTION_NAME ($SUBSCRIPTION_ID)"

# Resolve the signed-in identity's object ID
SIGNED_IN_USER_TYPE=$(az account show --query "user.type" -o tsv)
if [[ "$SIGNED_IN_USER_TYPE" == "user" ]]; then
  PRINCIPAL_TYPE="User"
  PRINCIPAL_ID=$(az ad signed-in-user show --query id -o tsv)
  PRINCIPAL_NAME=$(az ad signed-in-user show --query userPrincipalName -o tsv)
elif [[ "$SIGNED_IN_USER_TYPE" == "servicePrincipal" ]]; then
  PRINCIPAL_TYPE="ServicePrincipal"
  APP_ID=$(az account show --query "user.name" -o tsv)
  PRINCIPAL_ID=$(az ad sp show --id "$APP_ID" --query id -o tsv)
  PRINCIPAL_NAME="$APP_ID"
else
  fail "Unsupported identity type: $SIGNED_IN_USER_TYPE"
fi
info "Signed-in principal: $PRINCIPAL_NAME ($PRINCIPAL_TYPE)"

# ── Storage account name ────────────────────────────────────────────────────
if [[ -z "$STORAGE_ACCOUNT" ]]; then
  STORAGE_ACCOUNT="sttfstate$(short_hash "$SUBSCRIPTION_ID")"
fi

if [[ ! "$STORAGE_ACCOUNT" =~ ^[a-z0-9]{3,24}$ ]]; then
  fail "Invalid storage account name '$STORAGE_ACCOUNT'. Must be 3-24 lowercase letters/digits."
fi

info "Configuration:"
info "  Resource Group:   $RESOURCE_GROUP"
info "  Location:         $LOCATION"
info "  Storage Account:  $STORAGE_ACCOUNT"
info "  Container:        $CONTAINER_NAME"
echo ""

# ── 1. Resource Group ───────────────────────────────────────────────────────
info "Creating resource group '$RESOURCE_GROUP' in '$LOCATION'..."
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --tags "${TAGS[@]}" \
  --output none
ok "Resource group ready."

# ── 2. Storage Account ─────────────────────────────────────────────────────
info "Creating storage account '$STORAGE_ACCOUNT'..."
az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku Standard_ZRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --https-only true \
  --allow-blob-public-access false \
  --allow-shared-key-access false \
  --tags "${TAGS[@]}" \
  --output none
ok "Storage account created with shared-key access DISABLED (Entra ID only)."

info "Enabling blob versioning and soft delete (state recovery)..."
az storage account blob-service-properties update \
  --account-name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --enable-versioning true \
  --enable-delete-retention true \
  --delete-retention-days 30 \
  --enable-container-delete-retention true \
  --container-delete-retention-days 30 \
  --output none
ok "Versioning and soft delete enabled."

# ── 3. Blob Container (control plane, no data-plane RBAC needed) ───────────
info "Creating blob container '$CONTAINER_NAME'..."
az storage container-rm create \
  --name "$CONTAINER_NAME" \
  --storage-account "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --public-access off \
  --output none
ok "Blob container '$CONTAINER_NAME' ready."

# ── 4. RBAC ─────────────────────────────────────────────────────────────────
STORAGE_ACCOUNT_ID=$(az storage account show \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --query id -o tsv)

ROLE="Storage Blob Data Contributor"
EXISTING=$(az role assignment list \
  --assignee "$PRINCIPAL_ID" \
  --role "$ROLE" \
  --scope "$STORAGE_ACCOUNT_ID" \
  --query "[].id" -o tsv 2>/dev/null || true)

if [[ -n "$EXISTING" ]]; then
  ok "Role '$ROLE' already assigned."
else
  info "Assigning role '$ROLE'..."
  az role assignment create \
    --assignee-object-id "$PRINCIPAL_ID" \
    --assignee-principal-type "$PRINCIPAL_TYPE" \
    --role "$ROLE" \
    --scope "$STORAGE_ACCOUNT_ID" \
    --output none
  ok "Role '$ROLE' assigned."
fi

echo ""
ok "Bootstrap complete!"
echo ""
info "Initialise Terraform (do not commit these values). Use one state key per stack/environment:"
echo ""
echo "  # Platform (management groups, policy) - run from ./platform"
echo "  terraform init -backend-config=\"resource_group_name=$RESOURCE_GROUP\" \\"
echo "    -backend-config=\"storage_account_name=$STORAGE_ACCOUNT\" \\"
echo "    -backend-config=\"container_name=$CONTAINER_NAME\" \\"
echo "    -backend-config=\"key=platform.tfstate\""
echo ""
echo "  # Landing zone - run from the repository root, key per environment"
echo "  terraform init -backend-config=\"resource_group_name=$RESOURCE_GROUP\" \\"
echo "    -backend-config=\"storage_account_name=$STORAGE_ACCOUNT\" \\"
echo "    -backend-config=\"container_name=$CONTAINER_NAME\" \\"
echo "    -backend-config=\"key=data-ai-landing-zone-dev.tfstate\""
echo ""
warn "RBAC propagation can take a few minutes. If 'terraform init' returns 403, wait and retry."
echo ""
info "For CI/CD, grant the same role to each pipeline identity:"
echo ""
echo "  az role assignment create \\"
echo "    --assignee-object-id <SP_OBJECT_ID> \\"
echo "    --assignee-principal-type ServicePrincipal \\"
echo "    --role '$ROLE' \\"
echo "    --scope $STORAGE_ACCOUNT_ID"
