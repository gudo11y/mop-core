local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local helm = tanka.helm.new(std.thisFile);
local common = import 'common.libsonnet';

{
  prometheus: helm.template(
    name='prometheus',
    chart='./charts/prometheus',
    conf={
      namespace: common.namespace,
      values+: {
        server+: {
          extraFlags+: [
            'web.enable-admin-api',
          ],
          ingress+: {
            enabled: true,
            hosts: [
              'prometheus.gudo11y.local',
            ],
          },
        },

      },
    }
  ),
}
