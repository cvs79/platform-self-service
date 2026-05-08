# Platform Self-Service

This repository contains self-service resources for development teams.

## Structure

- `namespaces/`: Kubernetes namespace definitions organized by environment
  - `dev/`: Development environment namespaces
  - `staging/`: Staging environment namespaces
  - `prod/`: Production environment namespaces
- `projects/`: ArgoCD project definitions
- `applications/`: ArgoCD application definitions

## How to Request Resources

1. Create a branch for your request
2. Add your resource definition in the appropriate directory
3. Submit a Pull Request
4. Once approved and merged, ArgoCD will automatically create the resources

## Example: Requesting a New Namespace

```bash
# 1. Create a new branch
git checkout -b request-myteam-namespace

# 2. Create your namespace file (use existing examples as templates)
cp namespaces/dev/frontend-dev-namespace.yaml namespaces/dev/myteam-dev-namespace.yaml
# Edit the file with your team's details

# 3. Commit and push
git add namespaces/dev/myteam-dev-namespace.yaml
git commit -m "Request namespace for myteam in dev environment"
git push origin request-myteam-namespace

# 4. Create a Pull Request on GitHub
# 5. After PR is approved and merged, ArgoCD will create your namespace


## Azure Resources

This repository also contains Azure resource definitions managed through Azure Service Operator and ArgoCD.

### Structure

- `azure-resources/resource-groups/` - Azure Resource Group definitions
- `azure-resources/storage-accounts/` - Azure Storage Account definitions

### Workflow

1. Define Azure resources as Kubernetes manifests
2. Commit and push changes to GitHub
3. ArgoCD automatically syncs and applies changes
4. Azure Service Operator creates/updates Azure resources
