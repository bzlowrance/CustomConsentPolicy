#!/bin/bash

# Grant admin consent for all permissions on your application
# This bypasses user consent entirely for the specified permissions

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/consent-policy.cfg"

# Load configuration
if [ ! -f "$CONFIG_FILE" ]; then
    echo "✗ Configuration file not found: $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Grant Admin Consent for Application"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "App ID: $APP_ID"
echo "Tenant: $TENANT_ID"
echo ""

# Step 1: Login check
echo "[1/4] Checking Azure login..."
TENANT_CHECK=$(az account show --query tenantId -o tsv 2>/dev/null || echo "")
if [ "$TENANT_CHECK" != "$TENANT_ID" ]; then
    echo "Please login to correct tenant..."
    az login --tenant "$TENANT_ID"
fi
echo "✓ Logged in"
echo ""

# Step 2: Get admin consent URL
echo "[2/4] Generating admin consent URL..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Admin Consent URL:"
echo ""
echo "$LOGIN_ENDPOINT/$TENANT_ID/adminconsent?client_id=$APP_ID"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Option 1: Open this URL in your browser and approve"
echo "Option 2: Use Azure CLI to grant consent (below)"
echo ""
read -p "Use Azure CLI to grant consent now? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo ""
    echo "You can grant consent manually by:"
    echo "1. Opening the URL above in your browser"
    echo "2. Or going to Azure Portal > App Registrations > [Your App] > API permissions > Grant admin consent"
    echo ""
    exit 0
fi

echo ""

# Step 3: Get service principal
echo "[3/4] Getting service principal..."
SP_ID=$(az ad sp list --filter "appId eq '$APP_ID'" --query "[0].id" -o tsv)

if [ -z "$SP_ID" ]; then
    echo "⚠ Service principal not found. Creating one..."
    az ad sp create --id "$APP_ID"
    SP_ID=$(az ad sp list --filter "appId eq '$APP_ID'" --query "[0].id" -o tsv)
fi
echo "✓ Service Principal ID: $SP_ID"
echo ""

# Step 4: Grant admin consent using Graph API
echo "[4/4] Granting admin consent for all delegated permissions..."

# Microsoft Graph service principal
GRAPH_SP_ID=$(az ad sp list --filter "appId eq '$GRAPH_APP_ID'" --query "[0].id" -o tsv)

# Get current user (must be admin)
ADMIN_USER_ID=$(az ad signed-in-user show --query id -o tsv)

# Grant consent using OAuth2PermissionGrant
set +e  # Temporarily disable exit on error
CONSENT_RESULT=$(az rest --method POST \
    --uri "$GRAPH_ENDPOINT/v1.0/oauth2PermissionGrants" \
    --headers 'Content-Type=application/json' \
    --body "{
        \"clientId\": \"$SP_ID\",
        \"consentType\": \"AllPrincipals\",
        \"resourceId\": \"$GRAPH_SP_ID\",
        \"scope\": \"$PERM_NAMES\"
    }" 2>&1)

if [ $? -eq 0 ]; then
    echo "✓ Admin consent granted"
    set -e  # Re-enable exit on error
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ SUCCESS!"
    echo ""
    echo "Admin consent has been granted for:"
    # Display each permission from PERM_NAMES
    for perm in $PERM_NAMES; do
        echo "  • $perm"
    done
    echo ""
    echo "Users can now access the application without being"
    echo "prompted for these permissions."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
    set -e  # Re-enable exit on error
    echo "⚠ Could not grant consent via CLI"
    echo "  Error details: $CONSENT_RESULT"
    echo ""
    echo "Please use the admin consent URL above or:"
    echo "Azure Portal > App Registrations > [Your App] > API permissions > Grant admin consent"
fi

echo ""
