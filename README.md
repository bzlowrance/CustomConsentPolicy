# Azure Admin Consent for Applications

Grant admin consent to specific applications using **Azure CLI Bash scripts** - **no PowerShell, no VS Code REST Client needed**.

This streamlined approach provides application-specific consent control without the complexity of custom tenant-wide consent policies.

## 🚀 Quick Start

```bash
# Make script executable
./setup.sh

# Grant admin consent for your application
./grant-admin-consent.sh
```

**That's it!** Your users can now access the application without consent prompts.

---

## ⚙️ Configuration

The script reads from **`consent-policy.cfg`**. Update these values for your environment:

```bash
# View current configuration
cat consent-policy.cfg

# Edit if needed
nano consent-policy.cfg
```

**Key variables**:
- `CLOUD_ENVIRONMENT` - Azure cloud: `commercial`, `gcc`, `gcchigh`, or `dod`
- `TENANT_ID` - Your Azure AD Tenant ID
- `APP_ID` - Your Application (Client) ID
- `PERM_NAMES` - Space-separated list of permission names

---

## 🌐 Cloud Environment Setup

### Azure Commercial (Default)
```bash
# 1. Edit consent-policy.cfg:
CLOUD_ENVIRONMENT="commercial"

# 2. Set Azure CLI cloud
az cloud set --name AzureCloud

# 3. Login
az login --tenant <your-tenant-id>
```

### Azure Government
```bash
# 1. Edit consent-policy.cfg:
CLOUD_ENVIRONMENT="gcc"

# 2. Set Azure CLI cloud
az cloud set --name AzureUSGovernment

# 3. Login
az login --tenant <your-gov-tenant-id>
```

---

## 📝 What Admin Consent Does

When you grant admin consent:

✅ **Application-specific** - Only affects your configured app  
✅ **No user prompts** - Users can access the app immediately  
✅ **Tenant-safe** - Other applications are unaffected  
✅ **Easily reversible** - Can be removed in Azure Portal  

### Permissions Included:
- `Calendars.Read` - Read user calendars
- `OnlineMeetingArtifact.Read.All` - Read online meeting artifacts  
- `Presence.Read.All` - Read presence information
- `TeamsAppInstallation.ReadWriteForUser` - Manage Teams app installations
- `User.Read.All` - Read all users' profiles

---

## 🔧 Management

### View Admin Consent Status
Check in Azure Portal:
1. Go to **Enterprise Applications**
2. Find your application  
3. Navigate to **Permissions**

### Remove Admin Consent
In Azure Portal:
1. **Enterprise Applications** → Your App → **Permissions**
2. Remove the granted permissions

### Alternative: Browser-based Admin Consent
The script can also generate an admin consent URL that you can open in your browser for a GUI-based consent flow.

---

## 📋 Files in This Project

| File | Purpose |
|------|---------|
| `grant-admin-consent.sh` | Main script - grants admin consent |
| `consent-policy.cfg` | Configuration file |
| `setup.sh` | Makes scripts executable |
| `check-az.sh` | Checks Azure CLI installation |
| `APP-SPECIFIC-CONSENT-GUIDE.md` | Detailed guide on consent approaches |
| `PERMISSION-IDS.md` | Reference for permission IDs |

---

## 🆚 Why Admin Consent vs Custom Consent Policies?

| Approach | Scope | Complexity | Use Case |
|----------|-------|------------|----------|
| **Admin Consent** ✅ | Single app | Simple | App-specific control |
| Custom Consent Policies | Tenant-wide | Complex | Governance across all apps |

**For most application-specific needs, admin consent is the right choice.**

---

## 🔍 Troubleshooting

### Common Issues:

**"Not logged in"**
```bash
az login --tenant <your-tenant-id>
```

**"Permission denied"**  
Ensure you have one of these roles:
- Global Administrator
- Application Administrator  
- Cloud Application Administrator

**"App not found"**  
Check your `APP_ID` in `consent-policy.cfg`

---

## 📖 Additional Resources

- **APP-SPECIFIC-CONSENT-GUIDE.md** - Comprehensive guide explaining consent approaches
- **PERMISSION-IDS.md** - Reference for Microsoft Graph permission IDs
- [Microsoft Graph Permissions Reference](https://docs.microsoft.com/en-us/graph/permissions-reference)

---

## ✨ Benefits of This Approach

🎯 **Focused** - Does exactly what you need without complexity  
🚀 **Fast** - One command setup  
🔒 **Safe** - Application-specific, no tenant-wide changes  
📚 **Simple** - Easy to understand and maintain  
🔄 **Reversible** - Easy to undo if needed

**Perfect for developers, testers, and specific application deployments.**