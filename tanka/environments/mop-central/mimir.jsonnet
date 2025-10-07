local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local helm = tanka.helm.new(std.thisFile);
local common = import 'common.libsonnet';

{
  mimir: helm.template(
    name='mimir',
    chart='./charts/mimir-distributed',
    conf={
      namespace: common.namespace,
      values: {
        mimir: {
          structuredConfig: {
            multitenancy_enabled: false,
            ingester: {
              ring: {
                zone_awareness_enabled: false,
              },
            },
            store_gateway: {
              sharding_ring: {
                zone_awareness_enabled: false,
              },
            },
            usage_stats: {
              enabled: false,
            },
          },
        },
        // Disable zone-aware replication at chart level
        ingester: {
          zoneAwareReplication: {
            enabled: false,
          },
        },
        store_gateway: {
          zoneAwareReplication: {
            enabled: false,
          },
        },
        // Use distributed mode with separate components
        minio: {
          enabled: true,
        },
        // Use S3-compatible storage (MinIO) for distributed mode
        backend: 's3',
        metaMonitoring: {
          serviceMonitor: {
            enabled: true,
          },
        },
      },
    }
  ),
}
