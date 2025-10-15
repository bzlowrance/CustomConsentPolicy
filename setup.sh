#!/bin/bash
# Make scripts executable
# Run this once after downloading/cloning

chmod +x grant-admin-consent.sh
chmod +x check-az.sh

echo "✓ Scripts are now executable"
echo ""
echo "Checking Azure CLI availability..."
./check-az.sh
echo ""
echo "🚀 Ready! Run './grant-admin-consent.sh' to grant admin consent for your app."
