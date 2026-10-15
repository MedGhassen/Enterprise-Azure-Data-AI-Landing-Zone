#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Bootstrap Azure Storage for Terraform state with Entra ID (Azure AD) auth
#
# This script:
#   1. Creates a resource group and storage account for Terraform state
#   2. Creates a blob container for the state file
#   3. Disables shared-key / storage-key access (enforces Entra ID only)
#   4. Assigns "Storage Blob Data Contributor" to the current signed-in user
#      so Terraform can read/write state via Entra ID tokens
#
# Prerequisites:
#   - Azure CLI >= 2.50 installed and logged in (`az login`)
#   - Sufficient permissions: Contributor + User Access Administrator (or Owner)
#     on the target subscription
#
# Usage:
#   ./scripts/bootstrap-state.sh                          # uses defaults
#   ./scripts/bootstrap-state.sh -l northeurope           # override location
#   ./scripts/bootstrap-state.sh -g my-rg -s mystorage01  # override names
###############################################################################

# ── Defaults (override via flags) ───────────────────────────────────────────
RESOURCE_GROUP="rg-terraform-state"
LOCATION="westeurope"
STORAGE_ACCOUNT=""          # auto-generated if empty
CONTAINER_NAME="tfstate"
TAGS="purpose=terraform-state managed-by=bootstrap-script"

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -g  Resource group name         (default: $RESOURCE_GROUP)
  -l  Azure region / location     (default: $LOCATION)
  -s  Storage account name        (default: auto-generated)
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
    h) usage ;;
    *) usage ;;
  esac
done

# ── Helpers ─────────────────────────────────────────────────────────────────
info()  { printf "\033[1;34m▶ %s\033[0m\n" "$*"; }
ok()    { printf "\033[1;32m✔ %s\033[0m\n" "$*"; }
warn()  { printf "\033[1;33m⚠ %s\033[0m\n" "$*"; }
fail()  { printf "\033[1;31m✖ %s\033[0m\n" "$*" >&2; exit 1; }

# ── Pre-flight checks ──────────────────────────────────────────────────────
command -v az >/dev/null 2>&1 || fail "Azure CLI (az) is not installed."
az account show >/dev/null 2>&1 || fail "Not logged in. Run 'az login' first."

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
info "Active subscription: $SUBSCRIPTION_NAME ($SUBSCRIPTION_ID)"

# Resolve current signed-in identity
SIGNED_IN_USER_TYPE=$(az account show --query "user.type" -o tsv)
if [[ "$SIGNED_IN_USER_TYPE" == "user" ]]; then
  PRINCIPAL_TYPE="User"
  PRINCIPAL_ID=$(az ad signed-in-user show --query id -o tsv)
  PRINCIPAL_NAME=$(az ad signed-in-user show --query userPrincipalName -o tsv)
elif [[ "$SIGNED_IN_USER_TYPE" == "servicePrincipal" ]]; then
  PRINCIPAL_TYPE="ServicePrincipal"
  PRINCIPAL_ID=$(az account show --query "user.name" -o tsv)
  PRINCIPAL_NAME="$PRINCIPAL_ID"
else
  fail "Unsupported identity type: $SIGNED_IN_USER_TYPE"
fi
info "Signed-in principal: $PRINCIPAL_NAME ($PRINCIPAL_TYPE)"

# ── Auto-generate storage account name if not provided ──────────────────────
if [[ -z "$STORAGE_ACCOUNT" ]]; then
  SUFFIX=$(echo -n "${SUBSCRIPTION_ID}" | md5sum | cut -c1-8)
  STORAGE_ACCOUNT="sttfstate${SUFFIX}"
fi

# Validate storage account name (3-24 lowercase alphanumeric)
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
  --tags $TAGS \
  --output none
ok "Resource group ready."

# ── 2. Storage Account ─────────────────────────────────────────────────────
info "Creating storage account '$STORAGE_ACCOUNT'..."
az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --https-only true \
  --allow-blob-public-access false \
  --allow-shared-key-access false \
  --tags $TAGS \
  --output none
ok "Storage account created with shared-key access DISABLED (Entra ID only)."

# ── 3. Blob Container ──────────────────────────────────────────────────────
info "Creating blob container '$CONTAINER_NAME'..."

# We need RBAC before we can create the container via data-plane with Entra ID,
# so temporarily use ARM control-plane to create it.
az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$STORAGE_ACCOUNT" \
  --auth-mode login \
  --output none 2>/dev/null || true

# Fallback: use ARM to create if data-plane fails (RBAC not yet propagated)
CONTAINER_EXISTS=$(az storage container exists \
  --name "$CONTAINER_NAME" \
  --account-name "$STORAGE_ACCOUNT" \
  --auth-mode login \
  --query exists -o tsv 2>/dev/null || echo "false")

if [[ "$CONTAINER_EXISTS" != "true" ]]; then
  info "Creating container via ARM..."
  az resource create \
    --resource-group "$RESOURCE_GROUP" \
    --resource-type "Microsoft.Storage/storageAccounts/blobServices/containers" \
    --name "${STORAGE_ACCOUNT}/default/${CONTAINER_NAME}" \
    --properties '{}' \
    --output none
fi
ok "Blob container '$CONTAINER_NAME' ready."

# ── 4. RBAC Role Assignments ───────────────────────────────────────────────
STORAGE_ACCOUNT_ID=$(az storage account show \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --query id -o tsv)

assign_role() {
  local role="$1"
  local scope="$2"

  EXISTING=$(az role assignment list \
    --assignee "$PRINCIPAL_ID" \
    --role "$role" \
    --scope "$scope" \
    --query "[].id" -o tsv 2>/dev/null || true)

  if [[ -n "$EXISTING" ]]; then
    ok "Role '$role' already assigned."
  else
    info "Assigning role '$role'..."
    az role assignment create \
      --assignee-object-id "$PRINCIPAL_ID" \
      --assignee-principal-type "$PRINCIPAL_TYPE" \
      --role "$role" \
      --scope "$scope" \
      --output none
    ok "Role '$role' assigned."
  fi
}

# Storage Blob Data Contributor — read/write/delete blobs (state files)
assign_role "Storage Blob Data Contributor" "$STORAGE_ACCOUNT_ID"

echo ""
ok "Bootstrap complete!"
echo ""
info "Run Terraform init with the following backend config (do not commit these values):"
echo ""
echo "  terraform init -backend-config=\"resource_group_name=$RESOURCE_GROUP\" \\"
echo "    -backend-config=\"storage_account_name=$STORAGE_ACCOUNT\" \\"
echo "    -backend-config=\"container_name=$CONTAINER_NAME\" \\"
echo "    -backend-config=\"key=data-ai-landing-zone.tfstate\""
echo ""
warn "RBAC propagation may take up to 5 minutes. If 'terraform init' fails with"
warn "403, wait a moment and retry."
echo ""
info "For CI/CD pipelines, assign the same 'Storage Blob Data Contributor' role"
info "to each pipeline service principal / managed identity:"
echo ""
echo "  az role assignment create \\"
echo "    --assignee-object-id <SP_OBJECT_ID> \\"
echo "    --assignee-principal-type ServicePrincipal \\"
echo "    --role 'Storage Blob Data Contributor' \\"
echo "    --scope $STORAGE_ACCOUNT_ID"
