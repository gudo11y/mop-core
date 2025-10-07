// Example: Creating a SecretStore for Kubernetes backend
// This is useful for development/testing where secrets are stored as Kubernetes Secrets
//
// Usage:
//   1. Create a source Kubernetes secret:
//      kubectl create secret generic my-source-secret --from-literal=api-token=mytoken123
//
//   2. Apply this SecretStore:
//      tk apply tanka/environments/mop-edge (if included in main.jsonnet)
//      OR
//      kubectl apply -f <(tk show tanka/environments/mop-edge | yq 'select(.kind == "SecretStore")')

local eso = import 'eso.libsonnet';

{
  // Simple SecretStore using Kubernetes backend
  'secretstore-kubernetes': eso.secretStore.new(
    name='kubernetes-backend',
    namespace='mop'
  ),

  // ClusterSecretStore using Kubernetes backend (accessible from all namespaces)
  'clustersecretstore-kubernetes': eso.clusterSecretStore.kubernetes(
    name='kubernetes-backend-cluster',
    namespace='mop'
  ),

  // ClusterSecretStore for AWS Secrets Manager
  // Requires AWS IRSA or similar for authentication
  'clustersecretstore-aws': eso.clusterSecretStore.awsSecretsManager(
    name='aws-secrets-manager',
    region='us-east-1',
    role='arn:aws:iam::123456789012:role/external-secrets-role'
  ),

  // ClusterSecretStore for GCP Secret Manager
  // Requires GCP Workload Identity for authentication
  'clustersecretstore-gcp': eso.clusterSecretStore.gcpSecretManager(
    name='gcp-secret-manager',
    projectID='my-gcp-project'
  ),

  // ClusterSecretStore for HashiCorp Vault
  'clustersecretstore-vault': eso.clusterSecretStore.vault(
    name='vault-backend',
    server='https://vault.example.com:8200',
    path='secret',
    version='v2'
  ),
}
