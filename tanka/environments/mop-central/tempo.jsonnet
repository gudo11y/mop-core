local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local helm = tanka.helm.new(std.thisFile);
local common = import 'common.libsonnet';

{
  tempo: helm.template(
    name='tempo',
    chart='./charts/tempo-distributed',
    conf={
      namespace: common.namespace,
      values+: {
        traces: {
          otlp: {
            grpc: {
              enabled: true,
            },
            http: {
              enabled: true,
            },
          },
        },
        metricsGenerator: {
          enabled: true,
          remoteWriteUrl: 'http://prometheus-server.mop.svc.cluster.local/api/v1/write',
        },
        storage: {
          trace: {
            backend: 'local',
          },
        },
      },
    }
  ),
}
