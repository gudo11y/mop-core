# External Secrets Operator Examples

This directory contains example Jsonnet files demonstrating how to use External Secrets Operator (ESO) with the mop-core platform.

## Files

- **eso-secretstore.jsonnet**: Examples of creating SecretStores and ClusterSecretStores for various backends
- **eso-externalsecret.jsonnet**: Examples of creating ExternalSecrets with different patterns
- **eso-backstage-migration.jsonnet**: Real-world example showing how to migrate Backstage secrets to ESO

## Quick Start

### 1. Create Source Secrets (Kubernetes Backend)

For development/testing, create source Kubernetes secrets:

```bash
# API token example
kubectl create secret generic app-credentials \
  --namespace mop \
  --from-literal=username=admin \
  --from-literal=password=secret123 \
  --from-literal=api-token=token456

# Database credentials example
kubectl create secret generic postgres-config \
  --namespace mop \
  --from-literal=username=postgres \
  --from-literal=password=dbpassword \
  --from-literal=host=postgres.mop.svc.cluster.local \
  --from-literal=port=5432 \
  --from-literal=database=myapp
```

### 2. Apply SecretStore

Create a SecretStore to define the backend:

```bash
# Using the example file directly
kubectl apply -f <(tk show . <<< 'import "examples/eso-secretstore.jsonnet"' | yq 'select(.kind == "SecretStore")')

# Or include in your environment's main.jsonnet
```

### 3. Apply ExternalSecrets

Create ExternalSecrets to sync from backend:

```bash
# Using the example file directly
kubectl apply -f <(tk show . <<< 'import "examples/eso-externalsecret.jsonnet"' | yq 'select(.kind == "ExternalSecret")')
```

### 4. Verify Secrets are Created

```bash
# Check ExternalSecret status
kubectl get externalsecrets -n mop

# Check that the target secret was created
kubectl get secrets -n mop

# View secret data (base64 decoded)
kubectl get secret my-api-token -n mop -o jsonpath='{.data.token}' | base64 -d
```

## Using Examples in Your Environment

### Option 1: Include in main.jsonnet

Add example resources directly to your environment:

```jsonnet
// In tanka/environments/mop-edge/main.jsonnet
local examples = import 'examples/eso-secretstore.jsonnet';

{
  // ... existing resources ...

  // Add ESO examples
  secretstore: examples['secretstore-kubernetes'],
}
```

### Option 2: Create Environment-Specific Files

Create `eso-config.jsonnet` in your environment:

```jsonnet
// In tanka/environments/mop-edge/eso-config.jsonnet
local eso = import 'eso.libsonnet';
local common = import 'common.libsonnet';

{
  secretStore: eso.secretStore.new('kubernetes-backend', common.namespace),

  apiTokenSecret: eso.patterns.apiTokenSecret(
    name='my-api-token',
    namespace=common.namespace,
    secretStore='kubernetes-backend',
    tokenKey='app-credentials'
  ),
}
```

Then include it in main.jsonnet:

```jsonnet
local esoConfig = import 'eso-config.jsonnet';

{
  // ... existing resources ...
  esoConfig: esoConfig,
}
```

## Production Patterns

### AWS Secrets Manager

```jsonnet
local eso = import 'eso.libsonnet';

{
  store: eso.clusterSecretStore.awsSecretsManager(
    name='aws-backend',
    region='us-east-1',
    role='arn:aws:iam::ACCOUNT_ID:role/external-secrets'
  ),

  secret: eso.externalSecret.new(
    name='prod-db-creds',
    namespace='mop',
    secretStore='aws-backend'
  ) + eso.externalSecret.withClusterSecretStore('aws-backend')
    + eso.externalSecret.withData('password', '/prod/database/password'),
}
```

### GCP Secret Manager

```jsonnet
local eso = import 'eso.libsonnet';

{
  store: eso.clusterSecretStore.gcpSecretManager(
    name='gcp-backend',
    projectID='my-project-123'
  ),

  secret: eso.externalSecret.new(
    name='prod-api-key',
    namespace='mop',
    secretStore='gcp-backend'
  ) + eso.externalSecret.withClusterSecretStore('gcp-backend')
    + eso.externalSecret.withData('api-key', 'prod-api-key'),
}
```

### HashiCorp Vault

```jsonnet
local eso = import 'eso.libsonnet';

{
  store: eso.clusterSecretStore.vault(
    name='vault-backend',
    server='https://vault.example.com:8200',
    path='secret/data',
    version='v2'
  ),

  secret: eso.externalSecret.new(
    name='vault-creds',
    namespace='mop',
    secretStore='vault-backend'
  ) + eso.externalSecret.withClusterSecretStore('vault-backend')
    + eso.externalSecret.withData('token', 'app/api-token'),
}
```

## Troubleshooting

### Check ESO Logs

```bash
kubectl logs -n mop -l app.kubernetes.io/name=external-secrets
```

### Check ExternalSecret Status

```bash
kubectl describe externalsecret my-api-token -n mop
```

### Common Issues

1. **ExternalSecret not syncing**: Check that the SecretStore/ClusterSecretStore is correctly configured
2. **Secret not found in backend**: Verify the `remoteRef.key` matches the actual secret name in your backend
3. **Permission errors**: Ensure the ESO service account has proper RBAC/IAM permissions

## References

- [External Secrets Operator Documentation](https://external-secrets.io/)
- [ESO API Reference](https://external-secrets.io/latest/api/externalsecret/)
- [Provider Documentation](https://external-secrets.io/latest/provider/aws-secrets-manager/)
