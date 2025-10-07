local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local helm = tanka.helm.new(std.thisFile);
local common = import 'common.libsonnet';

{
  backstage: helm.template(
    name='backstage',
    chart='./charts/backstage',
    conf={
      namespace: common.namespace,
      values+: {
        backstage+: {
          image+: {
            registry: 'localhost:5005',
            repository: 'backstage',
            tag: 'latest',
          },
          command: ['node', 'packages/backend'],
          containerPorts+: { backend: 7007 },
          appConfig+: {
            app: {
              title: 'Managed Observability Platform',
              baseUrl: 'http://localhost:3000',
            },
            organization: {
              name: 'gudo11y',
            },
            backend: {
              baseUrl: 'http://localhost:7007',
              listen: { port: 7007 },
              csp: { connectSrc: ["'self'", 'http:', 'https:'] },
              cors: { origin: ['http://localhost:3000'], methods: ['GET', 'HEAD', 'PATCH', 'POST', 'PUT', 'DELETE'], credentials: true },
              database: {
                client: 'pg',
                connection: {
                  host: '${POSTGRES_HOST}',
                  port: '${POSTGRES_PORT}',
                  user: 'postgres',
                  password: '${POSTGRES_PASSWORD}',
                },
              },
            },
            integrations: {},
            techdocs: {
              builder: 'local',
              generator: {
                runIn: 'docker',
              },
              publisher: {
                type: 'local',
              },
            },
            auth: {
              providers: {},
            },
            catalog+: {
              'import': {
                entityFilename: 'catalog-info.yaml',
                pullRequestBranchName: 'backstage-integration',
              },
              rules+: [{ allow: ['Component', 'System', 'API', 'Resource', 'Location'] }],
              locations+: [],
            },
            kubernetes: {
              serviceLocatorMethod: {
                type: 'multiTenant',
              },
              clusterLocatorMethods: [
                {
                  type: 'config',
                  clusters: [
                    {
                      url: 'https://kubernetes.default.svc',
                      name: 'k3d-prod',
                      authProvider: 'serviceAccount',
                      skipTLSVerify: false,
                      skipMetricsLookup: false,
                    },
                  ],
                },
              ],
            },
            permission: {
              enabled: 'false',
            },
          },
        },
        postgresql+: {
          enabled: 'true',
          image+: {
            registry: 'docker.io',
            repository: 'postgres',
            tag: '15-alpine',
          },
          auth+: {
            username: 'postgres',
            database: 'backstage',
            postgresPassword: '${POSTGRES_ADMIN_PASSWORD}',
          },
          primary+: {
            extraEnvVars: [
              {
                name: 'POSTGRES_USER',
                value: 'postgres',
              },
              {
                name: 'POSTGRES_DB',
                value: 'backstage',
              },
              {
                name: 'PGDATA',
                value: '/var/lib/postgresql/data/pgdata',
              },
            ],
          },
        },
        serviceAccount+: {
          create: true,
        },
      },
    },
  ),
}
