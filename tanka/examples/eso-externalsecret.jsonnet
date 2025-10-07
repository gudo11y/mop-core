// Example: Creating ExternalSecrets to sync secrets from backend stores
//
// Prerequisites:
//   1. A SecretStore or ClusterSecretStore must exist
//   2. Source secrets must exist in the backend (Kubernetes, AWS, GCP, Vault, etc.)
//
// For Kubernetes backend example:
//   kubectl create secret generic app-credentials \
//     --from-literal=username=admin \
//     --from-literal=password=secret123 \
//     --from-literal=api-token=token456

local eso = import 'eso.libsonnet';

{
  // Example 1: Simple API token secret
  'externalsecret-api-token': eso.patterns.apiTokenSecret(
    name='my-api-token',
    namespace='mop',
    secretStore='kubernetes-backend',
    tokenKey='app-credentials'  // References the Kubernetes secret name
  ),

  // Example 2: Database credentials with structured data
  'externalsecret-database': eso.patterns.databaseSecret(
    name='postgres-credentials',
    namespace='mop',
    secretStore='kubernetes-backend',
    dbSecretKey='postgres-config'  // Should contain username, password, host, port, database
  ),

  // Example 3: TLS certificate
  'externalsecret-tls': eso.patterns.tlsSecret(
    name='app-tls-cert',
    namespace='mop',
    secretStore='kubernetes-backend',
    certKey='tls-cert',  // Kubernetes secret containing the certificate
    keyKey='tls-key'  // Kubernetes secret containing the private key
  ),

  // Example 4: Custom ExternalSecret with multiple keys
  'externalsecret-custom': eso.externalSecret.new(
    name='app-config',
    namespace='mop',
    secretStore='kubernetes-backend',
    refreshInterval='5m'
  ) + eso.externalSecret.withData('username', 'app-credentials')
  + eso.externalSecret.withDataProperty('password', 'app-credentials', 'password')
  + eso.externalSecret.withDataProperty('api-key', 'app-credentials', 'api-token'),

  // Example 5: Using ClusterSecretStore instead of namespaced SecretStore
  'externalsecret-cluster-store': eso.externalSecret.new(
    name='shared-credentials',
    namespace='mop',
    secretStore='kubernetes-backend-cluster',  // References a ClusterSecretStore
    refreshInterval='1h'
  ) + eso.externalSecret.withClusterSecretStore('kubernetes-backend-cluster')
  + eso.externalSecret.withData('token', 'shared-api-token'),

  // Example 6: ExternalSecret with custom target name and template
  'externalsecret-templated': eso.externalSecret.new(
    name='app-env-vars',
    namespace='mop',
    secretStore='kubernetes-backend'
  ) + eso.externalSecret.withTargetName('application-environment')
  + eso.externalSecret.withData('db_user', 'postgres-config')
  + eso.externalSecret.withData('db_pass', 'postgres-config')
  + eso.externalSecret.withTemplate({
    type: 'Opaque',
    data: {
      DATABASE_URL: 'postgresql://{{ .db_user }}:{{ .db_pass }}@localhost:5432/mydb',
    },
  }),
}
