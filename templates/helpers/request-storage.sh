#!/bin/bash
# Interactive script to request Azure Storage Account
# This script generates YAML from templates and can optionally commit it

set -e

echo "==================================="
echo "   Azure Storage Request Tool"
echo "==================================="
echo

# Prompt for values
read -p "Team Name: " TEAM_NAME
read -p "Environment (dev/staging/prod): " ENVIRONMENT
read -p "Storage Account Name (3-24 chars, lowercase alphanumeric only): " STORAGE_NAME
read -p "Purpose: " PURPOSE
read -p "Azure Region (swedencentral/westeurope/northeurope): " AZURE_REGION
read -p "SKU (Standard_LRS/Standard_GRS): " SKU

# Validate storage name
if [[ ! "$STORAGE_NAME" =~ ^[a-z0-9]{3,24}$ ]]; then
    echo "❌ Error: Storage name must be 3-24 characters, lowercase alphanumeric only"
    exit 1
fi

# Get current date
DATE=$(date +%Y-%m-%d)

# Generate YAML
OUTPUT_DIR="../azure-resources/${TEAM_NAME}"
OUTPUT_FILE="${OUTPUT_DIR}/${STORAGE_NAME}.yaml"

# Create directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo
echo "Generating YAML file: $OUTPUT_FILE"
echo

# Generate the YAML file
cat > "$OUTPUT_FILE" << YAML
# Azure Storage Account Request
# Team: ${TEAM_NAME}
# Environment: ${ENVIRONMENT}
# Requested: ${DATE}
---
# Resource Group for Storage
apiVersion: resources.azure.com/v1api20200601
kind: ResourceGroup
metadata:
  name: ${TEAM_NAME}-${ENVIRONMENT}-storage-rg
  namespace: default
spec:
  location: ${AZURE_REGION}
  tags:
    team: ${TEAM_NAME}
    environment: ${ENVIRONMENT}
    resource-type: storage
    managed-by: platform-team
    created-via: self-service
    requested-date: "${DATE}"
---
# Storage Account
apiVersion: storage.azure.com/v1api20230101
kind: StorageAccount
metadata:
  name: ${STORAGE_NAME}
  namespace: default
spec:
  location: ${AZURE_REGION}
  kind: StorageV2
  sku:
    name: ${SKU}
  owner:
    name: ${TEAM_NAME}-${ENVIRONMENT}-storage-rg
  accessTier: Hot
  tags:
    team: ${TEAM_NAME}
    environment: ${ENVIRONMENT}
    purpose: "${PURPOSE}"
    managed-by: platform-team
    created-via: self-service
YAML

echo "✅ YAML file generated successfully!"
echo
echo "File location: $OUTPUT_FILE"
echo
echo "Storage account name: ${STORAGE_NAME}"
echo "Resource group: ${TEAM_NAME}-${ENVIRONMENT}-storage-rg"
echo

# Show the file contents
cat "$OUTPUT_FILE"

echo
echo "=================================="
echo "Next Steps:"
echo "=================================="
echo "1. Review the generated YAML above"
echo "2. Commit the file to git:"
echo "   cd $(dirname $OUTPUT_DIR)"
echo "   git add $OUTPUT_FILE"
echo "   git commit -m 'Request storage account ${STORAGE_NAME}'"
echo "   git push origin main"
echo "3. Create a Pull Request on GitHub"
echo "4. After PR approval, ArgoCD and ASO will create the storage account"
echo

read -p "Would you like to commit this file now? (y/n): " COMMIT_NOW

if [[ "$COMMIT_NOW" == "y" || "$COMMIT_NOW" == "Y" ]]; then
    cd "$(dirname $OUTPUT_DIR)"
    git add "$OUTPUT_FILE"
    git commit -m "Request Azure storage account ${STORAGE_NAME}

Team: ${TEAM_NAME}
Environment: ${ENVIRONMENT}
Purpose: ${PURPOSE}
Region: ${AZURE_REGION}
SKU: ${SKU}"

    echo
    echo "✅ Changes committed locally!"
    echo "Run 'git push origin main' to push to GitHub and create a PR"
fi

echo
echo "Done!"
