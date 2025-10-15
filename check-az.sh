#!/bin/bash
# Azure CLI Path Check and Test
# Run this if "az" command is not found in your bash session

echo "========================================"
echo "Azure CLI Path Check"
echo "========================================"
echo ""

# Check if az command is available
echo "Checking if Azure CLI is available..."

if command -v az &> /dev/null; then
    echo "✓ Azure CLI is available"
    echo ""
    
    # Get version
    AZ_VERSION=$(az version --output json 2>/dev/null | grep -o '"azure-cli": "[^"]*"' | cut -d'"' -f4)
    echo "Azure CLI Version: $AZ_VERSION"
    
    # Get location
    AZ_PATH=$(which az)
    echo "Azure CLI Location: $AZ_PATH"
    echo ""
    
    # Check login status
    echo "Checking Azure login status..."
    if az account show &> /dev/null; then
        ACCOUNT_NAME=$(az account show --query user.name -o tsv)
        TENANT_ID=$(az account show --query tenantId -o tsv)
        echo "✓ Logged in as: $ACCOUNT_NAME"
        echo "  Tenant: $TENANT_ID"
    else
        echo "✗ Not logged in"
        echo ""
        echo "To login, run:"
        echo "  az login --tenant 55119d87-7d79-4674-b29a-dd8504625262"
    fi
    
    echo ""
    echo "========================================"
    echo "SUCCESS - Azure CLI is ready to use!"
    echo "========================================"
echo ""
echo "You can now run:"
echo "  ./grant-admin-consent.sh"
echo ""else
    echo "✗ Azure CLI not found"
    echo ""
    echo "========================================"
    echo "TROUBLESHOOTING"
    echo "========================================"
    echo ""
    
    # Check if running in Git Bash on Windows
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        echo "Detected: Git Bash on Windows"
        echo ""
        echo "Azure CLI should be installed at:"
        echo "  C:/Program Files/Microsoft SDKs/Azure/CLI2/wbin/az.cmd"
        echo ""
        
        # Check if it exists
        if [ -f "/c/Program Files/Microsoft SDKs/Azure/CLI2/wbin/az.cmd" ]; then
            echo "✓ Azure CLI is installed"
            echo ""
            echo "Git Bash needs to be restarted to see Azure CLI."
            echo ""
            echo "Solutions:"
            echo "  1. Close and reopen Git Bash (recommended)"
            echo "  2. Close and reopen VS Code completely"
            echo "  3. Run: source ~/.bashrc"
            echo ""
            echo "After restart, Azure CLI will be available via:"
            echo "  az.cmd --version"
            echo "  or just: az --version"
        else
            echo "✗ Azure CLI not installed"
            echo ""
            echo "Install Azure CLI:"
            echo "  1. Open PowerShell as Administrator"
            echo "  2. Run: winget install Microsoft.AzureCLI"
            echo "  3. Close and reopen Git Bash"
        fi
        
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Detected: Linux"
        echo ""
        echo "Install Azure CLI:"
        echo "  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
        echo ""
        echo "Or for RPM-based distributions:"
        echo "  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc"
        echo "  sudo dnf install azure-cli"
        
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Detected: macOS"
        echo ""
        echo "Install Azure CLI:"
        echo "  brew install azure-cli"
    fi
    
    echo ""
    echo "See: https://aka.ms/azure-cli"
    echo ""
    
    exit 1
fi
