// Example: Migrating Backstage secrets to use External Secrets Operator
//
// This shows how to replace the hardcoded secrets in backstage.jsonnet
// with ExternalSecrets managed by ESO.
//
// Steps to migrate:
//   1. Create source secrets in your backend (e.g., Kubernetes, AWS, etc.)
//   2. Create a SecretStore (see eso-secretstore.jsonnet)
//   3. Create these ExternalSecrets
//   4. Update backstage.jsonnet to reference the ESO-managed secrets
//
// For Kubernetes backend, create source secrets:
//   kubectl create secret generic backstage-postgres-creds \
//     --from-literal=username=postgres \
//     --from-literal=password=YOUR_POSTGRES_PASSWORD \
//     --from-literal=host=backstage-postgresql \
//     --from-literal=port=5432 \
//     --from-literal=database=backstage
//
//   kubectl create secret generic backstage-github-app \
//     --from-literal=client-id=YOUR_GITHUB_CLIENT_ID \
//     --from-literal=client-secret=YOUR_GITHUB_CLIENT_SECRET \
//     --from-literal=webhook-secret=YOUR_WEBHOOK_SECRET

local eso = import 'eso.libsonnet';

{
  // PostgreSQL credentials for Backstage
  'backstage-postgres-external-secret': {
    apiVersion: 'external-secrets.io/v1beta1',
    kind: 'ExternalSecret',
    metadata: {
      name: 'backstage-postgresql',
      namespace: 'mop',
    },
    spec: {
      refreshInterval: '1h',
      secretStoreRef: {
        name: 'kubernetes-backend',
        kind: 'SecretStore',
      },
      target: {
        name: 'backstage-postgresql',
        creationPolicy: 'Owner',
        template: {
          type: 'Opaque',
          data: {
            // Key name matches what Backstage expects
            'postgres-password': '{{ .password }}',
            'username': '{{ .username }}',
            'host': '{{ .host }}',
            'port': '{{ .port }}',
            'database': '{{ .database }}',
          },
        },
      },
      data: [
        {
          secretKey: 'password',
          remoteRef: {
            key: 'backstage-postgres-creds',
            property: 'password',
          },
        },
        {
          secretKey: 'username',
          remoteRef: {
            key: 'backstage-postgres-creds',
            property: 'username',
          },
        },
        {
          secretKey: 'host',
          remoteRef: {
            key: 'backstage-postgres-creds',
            property: 'host',
          },
        },
        {
          secretKey: 'port',
          remoteRef: {
            key: 'backstage-postgres-creds',
            property: 'port',
          },
        },
        {
          secretKey: 'database',
          remoteRef: {
            key: 'backstage-postgres-creds',
            property: 'database',
          },
        },
      ],
    },
  },

  // GitHub App credentials for Backstage
  'backstage-github-external-secret': {
    apiVersion: 'external-secrets.io/v1beta1',
    kind: 'ExternalSecret',
    metadata: {
      name: 'github-app-mop-backstage-credentials',
      namespace: 'mop',
    },
    spec: {
      refreshInterval: '1h',
      secretStoreRef: {
        name: 'kubernetes-backend',
        kind: 'SecretStore',
      },
      target: {
        name: 'github-app-mop-backstage-credentials',
        creationPolicy: 'Owner',
        template: {
          type: 'Opaque',
          data: {
            GITHUB_CLIENT_ID: '{{ .clientId }}',
            GITHUB_CLIENT_SECRET: '{{ .clientSecret }}',
            GITHUB_WEBHOOK_SECRET: '{{ .webhookSecret }}',
          },
        },
      },
      data: [
        {
          secretKey: 'clientId',
          remoteRef: {
            key: 'backstage-github-app',
            property: 'client-id',
          },
        },
        {
          secretKey: 'clientSecret',
          remoteRef: {
            key: 'backstage-github-app',
            property: 'client-secret',
          },
        },
        {
          secretKey: 'webhookSecret',
          remoteRef: {
            key: 'backstage-github-app',
            property: 'webhook-secret',
          },
        },
      ],
    },
  },
}
