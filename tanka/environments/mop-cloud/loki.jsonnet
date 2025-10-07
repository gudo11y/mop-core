local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local helm = tanka.helm.new(std.thisFile);
local common = import 'common.libsonnet';

{
  loki: helm.template(
    name='loki',
    chart='./charts/loki',
    conf={
      namespace: 'monitoring',
      values: {
        deploymentMode: 'SimpleScalable',
        loki: {
          auth_enabled: false,
          commonConfig: {
            replication_factor: 2,
          },
          storage: {
            type: 'filesystem',
          },
          schemaConfig: {
            configs: [
              {
                from: '2024-04-01',
                store: 'tsdb',
                object_store: 'filesystem',
                schema: 'v13',
                index: {
                  prefix: 'loki_index_',
                  period: '24h',
                },
              },
            ],
          },
        },
        singleBinary: {
          replicas: 0,
        },
        read: {
          replicas: 2,
        },
        write: {
          replicas: 2,
        },
        backend: {
          replicas: 2,
        },
      },
    }
  ),
}
