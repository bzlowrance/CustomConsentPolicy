# Azure Government Cloud Support

## Overview

All scripts now support Azure Government (GCC, GCC High, DoD) and Commercial clouds. The cloud environment is configured once in `consent-policy.cfg` and automatically applies to all scripts.

## Supported Cloud Environments

| Environment | CLOUD_ENVIRONMENT Value | Graph Endpoint | Login Endpoint |
|------------|------------------------|----------------|----------------|
| **Azure Government (GCC)** | `gcc` | `https://graph.microsoft.us` | `https://login.microsoftonline.us` |
| **Azure Government (GCC High)** | `gcchigh` | `https://graph.microsoft.us` | `https://login.microsoftonline.us` |
| **Azure Government (DoD)** | `dod` | `https://dod-graph.microsoft.us` | `https://login.microsoftonline.us` |
| Azure Commercial | `commercial` | `https://graph.microsoft.com` | `https://login.microsoftonline.com` |

**Default:** GCC (Azure Government)

## Configuration

### 1. Set Cloud Environment

Edit `consent-policy.cfg` and set the `CLOUD_ENVIRONMENT` variable:

```bash
# For Azure Government (GCC) - DEFAULT
CLOUD_ENVIRONMENT="gcc"

# For Azure Government (GCC High)
CLOUD_ENVIRONMENT="gcchigh"

# For Azure Government (DoD)
CLOUD_ENVIRONMENT="dod"

# For Azure Commercial Cloud
CLOUD_ENVIRONMENT="commercial"
```

### 2. Login to Azure CLI

Make sure you login to the correct cloud environment:

**Azure Government:**
```bash
az cloud set --name AzureUSGovernment
az login --tenant <your-tenant-id>
```

**Azure Commercial:**
```bash
az cloud set --name AzureCloud
az login --tenant <your-tenant-id>
```

### 3. Verify Cloud Configuration

Check your current cloud setting:
```bash
az cloud show --query name -o tsv
```

Expected output:
- Azure Government: `AzureUSGovernment`
- Azure Commercial: `AzureCloud`

## How It Works

The configuration file automatically sets the correct endpoints based on `CLOUD_ENVIRONMENT`:

```bash
# From consent-policy.cfg
case "$CLOUD_ENVIRONMENT" in
    "commercial")
        GRAPH_ENDPOINT="https://graph.microsoft.com"
        LOGIN_ENDPOINT="https://login.microsoftonline.com"
        ;;
    "gcc")
        GRAPH_ENDPOINT="https://graph.microsoft.us"
        LOGIN_ENDPOINT="https://login.microsoftonline.us"
        ;;
    "gcchigh")
        GRAPH_ENDPOINT="https://graph.microsoft.us"
        LOGIN_ENDPOINT="https://login.microsoftonline.us"
        ;;
    "dod")
        GRAPH_ENDPOINT="https://dod-graph.microsoft.us"
        LOGIN_ENDPOINT="https://login.microsoftonline.us"
        ;;
esac
```

All scripts automatically use these variables when making API calls.

## Affected Scripts

All 8 scripts support cloud configuration:

1. ✅ `create-consent-policy.sh` - Uses `$GRAPH_ENDPOINT`
2. ✅ `grant-admin-consent.sh` - Uses `$GRAPH_ENDPOINT` and `$LOGIN_ENDPOINT`
3. ✅ `set-tenant-default-policy.sh` - Uses `$GRAPH_ENDPOINT`
4. ✅ `assign-policy-to-app.sh` - Uses `$GRAPH_ENDPOINT`
5. ✅ `list-consent-policies.sh` - Uses `$GRAPH_ENDPOINT`
6. ✅ `get-consent-policy.sh` - Uses `$GRAPH_ENDPOINT`
7. ✅ `delete-consent-policy.sh` - Uses `$GRAPH_ENDPOINT`
8. ✅ `check-az.sh` - Cloud-agnostic (checks Azure CLI availability)

## Azure Government Differences

### Authentication Endpoints

Azure Government uses different OAuth endpoints:
- **Commercial:** `https://login.microsoftonline.com`
- **Government:** `https://login.microsoftonline.us`

### Graph API Endpoints

Azure Government uses different Graph API endpoints:
- **Commercial:** `https://graph.microsoft.com`
- **GCC/GCC High:** `https://graph.microsoft.us`
- **DoD:** `https://dod-graph.microsoft.us`

### Portal URLs

Azure Government uses different portal URLs:
- **Commercial Portal:** https://portal.azure.com
- **Government Portal:** https://portal.azure.us

## Quick Start Examples

### Scenario 1: Azure Government (GCC)

```bash
# 1. Configure for GCC (already default)
# Edit consent-policy.cfg:
CLOUD_ENVIRONMENT="gcc"

# 2. Login to Azure Government
az cloud set --name AzureUSGovernment
az login --tenant <your-gov-tenant-id>

# 3. Run scripts normally
./grant-admin-consent.sh
```

### Scenario 2: Switching from Commercial to Government

```bash
# 1. Update configuration
# Edit consent-policy.cfg:
CLOUD_ENVIRONMENT="gcc"  # Change from "commercial" to "gcc"

# 2. Switch Azure CLI cloud
az cloud set --name AzureUSGovernment
az logout
az login --tenant <your-gov-tenant-id>

# 3. Run scripts - they automatically use Gov endpoints
./create-consent-policy.sh
```

### Scenario 3: DoD Environment

```bash
# 1. Configure for DoD
# Edit consent-policy.cfg:
CLOUD_ENVIRONMENT="dod"

# 2. Login to DoD environment
az cloud set --name AzureUSGovernment
az login --tenant <your-dod-tenant-id>

# 3. Run scripts
./create-consent-policy.sh
```

## Troubleshooting

### Error: "Resource not found" or "404"

**Cause:** Azure CLI cloud setting doesn't match `CLOUD_ENVIRONMENT` in config.

**Solution:**
```bash
# Check current cloud
az cloud show --query name -o tsv

# For Government, should show:
# AzureUSGovernment

# If wrong, set it:
az cloud set --name AzureUSGovernment
az login --tenant <tenant-id>
```

### Error: "Unauthorized" or "403"

**Cause:** Logged into wrong tenant or insufficient permissions.

**Solution:**
```bash
# Verify logged in tenant
az account show --query tenantId -o tsv

# Compare to TENANT_ID in consent-policy.cfg
# If different, login to correct tenant:
az login --tenant <correct-tenant-id>
```

### Error: "Invalid URL" or "Name resolution failed"

**Cause:** Wrong endpoint for cloud environment.

**Solution:**
1. Check `CLOUD_ENVIRONMENT` in `consent-policy.cfg`
2. Verify it matches your actual Azure cloud (Government vs Commercial)
3. Re-run script - config is loaded fresh each time

### Scripts show wrong endpoints

**Cause:** Old terminal session cached config.

**Solution:**
```bash
# Simply re-run the script - config is reloaded automatically
./create-consent-policy.sh

# Config is sourced fresh each time, no cache
```

## Compliance Notes

### FedRAMP Compliance

- **GCC (Moderate):** General government use, FedRAMP Moderate
- **GCC High:** DoD Impact Level 5, FedRAMP High
- **DoD:** DoD Impact Level 6

### Data Residency

All Azure Government clouds store data in US datacenters with screened US personnel.

### ITAR Compliance

Azure Government (GCC High and DoD) supports ITAR (International Traffic in Arms Regulations) workloads.

## Additional Resources

- **Azure Government Documentation:** https://docs.microsoft.com/en-us/azure/azure-government/
- **Microsoft Graph for Government:** https://docs.microsoft.com/en-us/graph/deployments
- **Azure Government Portal:** https://portal.azure.us
- **Azure CLI Cloud Configuration:** https://docs.microsoft.com/en-us/cli/azure/manage-clouds-azure-cli

## Support

For issues specific to Azure Government endpoints:
1. Verify `CLOUD_ENVIRONMENT` setting in `consent-policy.cfg`
2. Confirm Azure CLI cloud setting: `az cloud show`
3. Check you're logged into correct tenant: `az account show`
4. Review script output for endpoint URLs being used

---

**Updated:** October 2025  
**Default Cloud:** Azure Government (GCC)
