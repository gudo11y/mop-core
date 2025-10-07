local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local helm = tanka.helm.new(std.thisFile);
local common = import 'common.libsonnet';

{
  tempo: helm.template(
    name='tempo',
    chart='./charts/tempo',
    conf={
      namespace: common.namespace,
      values: {
        tempo: {
          searchEnabled: true,
          metricsGenerator: {
            enabled: true,
            remoteWriteUrl: 'http://kube-prometheus-stack-prometheus.mop.svc.cluster.local:9090/api/v1/write',
          },
          storage: {
            trace: {
              backend: 'local',
              ['local']: {
                path: '/var/tempo/traces',
              },
            },
          },
        },
      },
    }
  ),
}
