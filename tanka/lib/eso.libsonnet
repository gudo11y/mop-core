local k = import 'k.libsonnet';

{
  // Helper to create a Kubernetes SecretStore (namespace-scoped)
  // Useful for development/testing with Kubernetes secrets as backend
  secretStore:: {
    new(name, namespace='mop'):: {
      apiVersion: 'external-secrets.io/v1beta1',
      kind: 'SecretStore',
      metadata: {
        name: name,
        namespace: namespace,
      },
      spec: {
        provider: {
          kubernetes: {
            remoteNamespace: namespace,
            server: {
              caProvider: {
                type: 'ConfigMap',
                name: 'kube-root-ca.crt',
                key: 'ca.crt',
              },
            },
            auth: {
              serviceAccount: {
                name: 'external-secrets',
              },
            },
          },
        },
      },
    },
  },

  // Helper to create a ClusterSecretStore (cluster-scoped)
  // Recommended for production use across multiple namespaces
  clusterSecretStore:: {
    // Kubernetes backend (for dev/testing)
    kubernetes(name, namespace='mop'):: {
      apiVersion: 'external-secrets.io/v1beta1',
      kind: 'ClusterSecretStore',
      metadata: {
        name: name,
      },
      spec: {
        provider: {
          kubernetes: {
            remoteNamespace: namespace,
            server: {
              caProvider: {
                type: 'ConfigMap',
                name: 'kube-root-ca.crt',
                key: 'ca.crt',
              },
            },
            auth: {
              serviceAccount: {
                name: 'external-secrets',
                namespace: namespace,
              },
            },
          },
        },
      },
    },

    // AWS Secrets Manager backend
    awsSecretsManager(name, region='us-east-1', role=''):: {
      apiVersion: 'external-secrets.io/v1beta1',
      kind: 'ClusterSecretStore',
      metadata: {
        name: name,
      },
      spec: {
        provider: {
          aws: {
            service: 'SecretsManager',
            region: region,
            auth: if role != '' then {
              jwt: {
                serviceAccountRef: {
                  name: 'external-secrets',
                },
              },
            } else {},
            role: role,
          },
        },
      },
    },

    // GCP Secret Manager backend
    gcpSecretManager(name, projectID=''):: {
      apiVersion: 'external-secrets.io/v1beta1',
      kind: 'ClusterSecretStore',
      metadata: {
        name: name,
      },
      spec: {
        provider: {
          gcpsm: {
            projectID: projectID,
            auth: {
              workloadIdentity: {
                clusterLocation: 'us-central1',
                clusterName: 'cluster-name',
                serviceAccountRef: {
                  name: 'external-secrets',
                },
              },
            },
          },
        },
      },
    },

    // HashiCorp Vault backend
    vault(name, server, path, version='v2'):: {
      apiVersion: 'external-secrets.io/v1beta1',
      kind: 'ClusterSecretStore',
      metadata: {
        name: name,
      },
      spec: {
        provider: {
          vault: {
            server: server,
            path: path,
            version: version,
            auth: {
              kubernetes: {
                mountPath: 'kubernetes',
                role: 'external-secrets',
                serviceAccountRef: {
                  name: 'external-secrets',
                },
              },
            },
          },
        },
      },
    },
  },

  // Helper to create an ExternalSecret
  externalSecret:: {
    new(name, namespace, secretStore, refreshInterval='1h'):: {
      apiVersion: 'external-secrets.io/v1beta1',
      kind: 'ExternalSecret',
      metadata: {
        name: name,
        namespace: namespace,
      },
      spec: {
        refreshInterval: refreshInterval,
        secretStoreRef: {
          name: secretStore,
          kind: 'SecretStore',
        },
        target: {
          name: name,
          creationPolicy: 'Owner',
        },
        data: [],
      },
    },

    // Add a single key mapping
    withData(key, remoteKey):: {
      data+: [{
        secretKey: key,
        remoteRef: {
          key: remoteKey,
        },
      }],
    },

    // Add a single key with property selection (for JSON secrets)
    withDataProperty(key, remoteKey, property):: {
      data+: [{
        secretKey: key,
        remoteRef: {
          key: remoteKey,
          property: property,
        },
      }],
    },

    // Use ClusterSecretStore instead of SecretStore
    withClusterSecretStore(name):: {
      spec+: {
        secretStoreRef: {
          name: name,
          kind: 'ClusterSecretStore',
        },
      },
    },

    // Set custom target secret name
    withTargetName(name):: {
      spec+: {
        target+: {
          name: name,
        },
      },
    },

    // Set target template (for custom secret formats)
    withTemplate(template):: {
      spec+: {
        target+: {
          template: template,
        },
      },
    },
  },

  // Common secret patterns
  patterns:: {
    // Database credentials pattern
    databaseSecret(name, namespace, secretStore, dbSecretKey):: {
      apiVersion: 'external-secrets.io/v1beta1',
      kind: 'ExternalSecret',
      metadata: {
        name: name,
        namespace: namespace,
      },
      spec: {
        refreshInterval: '1h',
        secretStoreRef: {
          name: secretStore,
          kind: 'SecretStore',
        },
        target: {
          name: name,
          creationPolicy: 'Owner',
          template: {
            type: 'Opaque',
            data: {
              username: '{{ .username }}',
              password: '{{ .password }}',
              host: '{{ .host }}',
              port: '{{ .port }}',
              database: '{{ .database }}',
            },
          },
        },
        data: [
          {
            secretKey: 'username',
            remoteRef: {
              key: dbSecretKey,
              property: 'username',
            },
          },
          {
            secretKey: 'password',
            remoteRef: {
              key: dbSecretKey,
              property: 'password',
            },
          },
          {
            secretKey: 'host',
            remoteRef: {
              key: dbSecretKey,
              property: 'host',
            },
          },
          {
            secretKey: 'port',
            remoteRef: {
              key: dbSecretKey,
              property: 'port',
            },
          },
          {
            secretKey: 'database',
            remoteRef: {
              key: dbSecretKey,
              property: 'database',
            },
          },
        ],
      },
    },

    // API token/key pattern
    apiTokenSecret(name, namespace, secretStore, tokenKey):: {
      apiVersion: 'external-secrets.io/v1beta1',
      kind: 'ExternalSecret',
      metadata: {
        name: name,
        namespace: namespace,
      },
      spec: {
        refreshInterval: '1h',
        secretStoreRef: {
          name: secretStore,
          kind: 'SecretStore',
        },
        target: {
          name: name,
          creationPolicy: 'Owner',
        },
        data: [
          {
            secretKey: 'token',
            remoteRef: {
              key: tokenKey,
            },
          },
        ],
      },
    },

    // TLS certificate pattern
    tlsSecret(name, namespace, secretStore, certKey, keyKey):: {
      apiVersion: 'external-secrets.io/v1beta1',
      kind: 'ExternalSecret',
      metadata: {
        name: name,
        namespace: namespace,
      },
      spec: {
        refreshInterval: '24h',
        secretStoreRef: {
          name: secretStore,
          kind: 'SecretStore',
        },
        target: {
          name: name,
          creationPolicy: 'Owner',
          template: {
            type: 'kubernetes.io/tls',
            data: {
              'tls.crt': '{{ .cert }}',
              'tls.key': '{{ .key }}',
            },
          },
        },
        data: [
          {
            secretKey: 'cert',
            remoteRef: {
              key: certKey,
            },
          },
          {
            secretKey: 'key',
            remoteRef: {
              key: keyKey,
            },
          },
        ],
      },
    },
  },
}
