#!/bin/bash
# Interactive script to request a Kubernetes namespace
# This script generates YAML from templates and can optionally commit it

set -e

echo "==================================="
echo "   Namespace Request Tool"
echo "==================================="
echo

# Prompt for values
read -p "Team Name (lowercase, no spaces): " TEAM_NAME
read -p "Environment (dev/staging/prod): " ENVIRONMENT
read -p "Contact Email: " CONTACT_EMAIL
read -p "Purpose: " PURPOSE
read -p "CPU Cores (1/2/4/8): " CPU_CORES
read -p "Memory GB (2/4/8/16): " MEMORY_GB

# Calculate limits (double the requests)
CPU_LIMIT=$((CPU_CORES * 2))
MEMORY_LIMIT=$((MEMORY_GB * 2))

# Get current date
DATE=$(date +%Y-%m-%d)

# Generate YAML
OUTPUT_DIR="../namespaces/${ENVIRONMENT}"
OUTPUT_FILE="${OUTPUT_DIR}/${TEAM_NAME}-namespace.yaml"

# Create directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo
echo "Generating YAML file: $OUTPUT_FILE"
echo

# Generate the YAML file
cat > "$OUTPUT_FILE" << YAML
# Kubernetes Namespace Request
# Team: ${TEAM_NAME}
# Environment: ${ENVIRONMENT}
# Requested: ${DATE}
---
apiVersion: v1
kind: Namespace
metadata:
  name: devops-${TEAM_NAME}-${ENVIRONMENT}
  labels:
    team: ${TEAM_NAME}
    environment: ${ENVIRONMENT}
    managed-by: platform-team
    created-via: self-service
  annotations:
    team.contact: "${CONTACT_EMAIL}"
    purpose: "${PURPOSE}"
    requested-date: "${DATE}"
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: ${TEAM_NAME}-${ENVIRONMENT}-quota
  namespace: devops-${TEAM_NAME}-${ENVIRONMENT}
spec:
  hard:
    requests.cpu: "${CPU_CORES}"
    requests.memory: "${MEMORY_GB}Gi"
    limits.cpu: "${CPU_LIMIT}"
    limits.memory: "${MEMORY_LIMIT}Gi"
    persistentvolumeclaims: "5"
    services: "10"
    pods: "20"
---
apiVersion: v1
kind: LimitRange
metadata:
  name: ${TEAM_NAME}-${ENVIRONMENT}-limits
  namespace: devops-${TEAM_NAME}-${ENVIRONMENT}
spec:
  limits:
  - default:
      cpu: 500m
      memory: 512Mi
    defaultRequest:
      cpu: 100m
      memory: 128Mi
    type: Container
YAML

echo "✅ YAML file generated successfully!"
echo
echo "File location: $OUTPUT_FILE"
echo
echo "Namespace that will be created: devops-${TEAM_NAME}-${ENVIRONMENT}"
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
echo "   git commit -m 'Request namespace for ${TEAM_NAME} ${ENVIRONMENT}'"
echo "   git push origin main"
echo "3. Create a Pull Request on GitHub"
echo "4. After PR approval, ArgoCD will sync the namespace"
echo

read -p "Would you like to commit this file now? (y/n): " COMMIT_NOW

if [[ "$COMMIT_NOW" == "y" || "$COMMIT_NOW" == "Y" ]]; then
    cd "$(dirname $OUTPUT_DIR)"
    git add "$OUTPUT_FILE"
    git commit -m "Request namespace for ${TEAM_NAME} in ${ENVIRONMENT} environment

Requested by: ${CONTACT_EMAIL}
Purpose: ${PURPOSE}
Resources: ${CPU_CORES} CPU cores, ${MEMORY_GB}GB memory"

    echo
    echo "✅ Changes committed locally!"
    echo "Run 'git push origin main' to push to GitHub and create a PR"
fi

echo
echo "Done!"
