local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local helm = tanka.helm.new(std.thisFile);
local common = import 'common.libsonnet';

{
  eso: helm.template(
    name='external-secrets',
    chart='./charts/external-secrets',
    conf={
      namespace: common.namespace,
      values+: {
        installCRDs: true,
        webhook+: {
          port: 9443,
        },
        certController+: {
          enabled: true,
        },
        serviceAccount+: {
          create: true,
          name: 'external-secrets',
        },
        rbac+: {
          create: true,
        },
        metrics+: {
          enabled: true,
          service+: {
            enabled: true,
          },
        },
        // Enable service monitor for Prometheus integration
        serviceMonitor+: {
          enabled: true,
          namespace: common.namespace,
        },
      },
    }
  ),
}
