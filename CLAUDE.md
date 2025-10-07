# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**mop-core** (Managed Observability Platform - Core) is a Kubernetes observability platform infrastructure project that deploys a complete observability stack using infrastructure-as-code. It's built with Tanka (Jsonnet + Kubernetes) and provides three deployment environments: central, cloud, and edge.

## Common Development Commands

### Tanka Operations
```bash
# Apply configuration to specific environment
tk apply tanka/environments/mop-edge

# Show generated manifests without applying
tk show tanka/environments/mop-edge

# Validate Jsonnet and Kubernetes manifests
tk validate tanka/environments/mop-edge

# Update Jsonnet dependencies
cd tanka && jb update

# Vendor Helm charts for specific environment
cd tanka/environments/mop-edge && tk tool charts vendor
```

### Tilt Local Development
```bash
# Start local development environment
tilt up

# Run with specific environment
tilt up -- --env mop-edge

# Setup Tilt environment (run once)
./scripts/tilt_setup.sh

# Build mop-edge environment
./scripts/tilt_build.sh
```

### Testing and Validation
```bash
# Validate all environments
for env in mop-central mop-cloud mop-edge; do
  tk validate tanka/environments/$env
done

# Generate and inspect manifests
tk show tanka/environments/mop-edge | kubectl apply --dry-run=client -f -
```

### External Secrets Operator (ESO)
```bash
# Check ESO deployment status
kubectl get pods -n mop -l app.kubernetes.io/name=external-secrets

# View installed CRDs
kubectl get crds | grep external-secrets

# List SecretStores
kubectl get secretstores -n mop
kubectl get clustersecretstores

# List ExternalSecrets and their sync status
kubectl get externalsecrets -n mop
kubectl describe externalsecret <name> -n mop

# Check if secrets were created successfully
kubectl get secrets -n mop

# View ESO logs for troubleshooting
kubectl logs -n mop -l app.kubernetes.io/name=external-secrets --tail=100

# Apply example SecretStore
kubectl apply -f <(tk show . <<< 'import "examples/eso-secretstore.jsonnet"' | yq 'select(.kind == "SecretStore")')

# Apply example ExternalSecret
kubectl apply -f <(tk show . <<< 'import "examples/eso-externalsecret.jsonnet"' | yq 'select(.kind == "ExternalSecret")')
```

## Architecture and Structure

### Core Technologies
- **Tanka**: Primary infrastructure-as-code tool using Jsonnet templating
- **Helm Charts**: For packaging observability applications
- **Tilt**: Local development workflow automation targeting minikube
- **Kubernetes**: Deployment platform (configured for minikube context)

### Observability Stack Components
The platform deploys: Prometheus, Grafana, Loki, Mimir, Tempo, Alloy/Alloy Operator, External Secrets Operator, and optionally Backstage.

### Three-Tier Environment Model
- **mop-central**: Central management environment
- **mop-cloud**: Cloud environment configuration
- **mop-edge**: Edge environment configuration

Each environment is a separate Tanka environment with its own:
- `spec.json` (Tanka environment specification)
- `chartfile.yaml` (Helm chart dependencies)
- `main.jsonnet` (Environment-specific configuration)

### Key Directory Structure
```
tanka/
├── lib/                     # Shared Jsonnet libraries
│   ├── common.libsonnet     # Common configurations and defaults
│   ├── eso.libsonnet       # External Secrets Operator helpers
│   ├── k.libsonnet         # Kubernetes utilities
│   └── utils.libsonnet     # Utility functions
├── examples/               # Example configurations and patterns
│   ├── eso-secretstore.jsonnet       # SecretStore examples
│   ├── eso-externalsecret.jsonnet    # ExternalSecret examples
│   └── eso-backstage-migration.jsonnet # Backstage ESO migration
├── environments/           # Environment-specific configurations
└── vendor/                # Vendored Jsonnet dependencies
```

### Dependency Management
- **jsonnetfile.json**: Manages Jsonnet library dependencies from Grafana Labs
- **chartfile.yaml**: Per-environment Helm chart dependencies
- **vendor/**: Jsonnet dependencies via `jb` (jsonnet-bundler)
- Charts are vendored per environment using `tk tool charts vendor`

### Development Workflow
1. Use Tilt for local development with live reloading
2. Modify Jsonnet configurations in `tanka/environments/`
3. Shared logic goes in `tanka/lib/` Libsonnet files
4. Validate changes with `tk validate` before applying
5. Environment changes are automatically detected by Tilt

### Configuration Patterns
- Environment-specific values are parameterized in `main.jsonnet`
- Common configurations are abstracted in `tanka/lib/common.libsonnet`
- Kubernetes utilities are available via `tanka/lib/k.libsonnet`
- All environments target minikube context by default

## Secret Management with External Secrets Operator

### ESO Architecture
External Secrets Operator (ESO) syncs secrets from external secret management systems (AWS Secrets Manager, GCP Secret Manager, HashiCorp Vault, Kubernetes Secrets, etc.) into Kubernetes Secrets.

**Key Components:**
- **SecretStore**: Namespace-scoped configuration for secret backend
- **ClusterSecretStore**: Cluster-scoped configuration for secret backend (recommended for production)
- **ExternalSecret**: Defines which secrets to sync and how to map them

### Using ESO Library (tanka/lib/eso.libsonnet)

The ESO library provides helpers for common secret patterns:

```jsonnet
local eso = import 'eso.libsonnet';

{
  // Create a SecretStore for Kubernetes backend (dev/testing)
  secretStore: eso.secretStore.new('kubernetes-backend', namespace='mop'),

  // Create a ClusterSecretStore for AWS Secrets Manager
  awsStore: eso.clusterSecretStore.awsSecretsManager(
    name='aws-backend',
    region='us-east-1',
    role='arn:aws:iam::123456789012:role/external-secrets'
  ),

  // Create an API token secret
  apiToken: eso.patterns.apiTokenSecret(
    name='my-api-token',
    namespace='mop',
    secretStore='kubernetes-backend',
    tokenKey='source-secret-name'
  ),

  // Create database credentials
  dbCreds: eso.patterns.databaseSecret(
    name='postgres-creds',
    namespace='mop',
    secretStore='kubernetes-backend',
    dbSecretKey='postgres-config'
  ),
}
```

### Backend Configurations

**Kubernetes Backend (Development):**
```jsonnet
local eso = import 'eso.libsonnet';
{
  store: eso.secretStore.new('kubernetes-backend', 'mop'),
}
```

**AWS Secrets Manager:**
```jsonnet
local eso = import 'eso.libsonnet';
{
  store: eso.clusterSecretStore.awsSecretsManager(
    name='aws-backend',
    region='us-east-1',
    role='arn:aws:iam::ACCOUNT:role/external-secrets'
  ),
}
```

**GCP Secret Manager:**
```jsonnet
local eso = import 'eso.libsonnet';
{
  store: eso.clusterSecretStore.gcpSecretManager(
    name='gcp-backend',
    projectID='my-project'
  ),
}
```

**HashiCorp Vault:**
```jsonnet
local eso = import 'eso.libsonnet';
{
  store: eso.clusterSecretStore.vault(
    name='vault-backend',
    server='https://vault.example.com:8200',
    path='secret'
  ),
}
```

### Creating ExternalSecrets

**Simple pattern:**
```jsonnet
local eso = import 'eso.libsonnet';
{
  secret: eso.externalSecret.new(
    name='my-secret',
    namespace='mop',
    secretStore='kubernetes-backend',
    refreshInterval='1h'
  ) + eso.externalSecret.withData('key', 'remote-secret-name'),
}
```

**With property selection (for JSON secrets):**
```jsonnet
local eso = import 'eso.libsonnet';
{
  secret: eso.externalSecret.new(
    name='my-secret',
    namespace='mop',
    secretStore='kubernetes-backend'
  ) + eso.externalSecret.withDataProperty('password', 'db-config', 'password'),
}
```

**Using ClusterSecretStore:**
```jsonnet
local eso = import 'eso.libsonnet';
{
  secret: eso.externalSecret.new(
    name='my-secret',
    namespace='mop',
    secretStore='aws-backend'
  ) + eso.externalSecret.withClusterSecretStore('aws-backend')
    + eso.externalSecret.withData('token', '/prod/api/token'),
}
```

### Examples

See `tanka/examples/` for comprehensive examples:
- `eso-secretstore.jsonnet`: SecretStore and ClusterSecretStore examples for all backends
- `eso-externalsecret.jsonnet`: ExternalSecret patterns (API tokens, database creds, TLS certs)
- `eso-backstage-migration.jsonnet`: Real-world migration example for Backstage secrets
- `README.md`: Detailed usage guide with troubleshooting

### Migration Pattern

To migrate existing hardcoded secrets to ESO:

1. Create source secrets in your backend
2. Create a SecretStore/ClusterSecretStore
3. Create ExternalSecrets to sync from backend
4. Update application manifests to reference ESO-managed secrets
5. Verify secrets are syncing correctly
6. Remove hardcoded secrets

See `tanka/examples/eso-backstage-migration.jsonnet` for a complete example.
