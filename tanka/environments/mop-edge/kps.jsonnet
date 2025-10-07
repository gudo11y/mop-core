local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local helm = tanka.helm.new(std.thisFile);
local common = import 'common.libsonnet';

{
  kps: helm.template(
    name='kube-prometheus-stack',
    chart='./charts/kube-prometheus-stack',
    conf={
      namespace: common.namespace,
      noHooks: false,
      includeCrds: false,
      values+: {
        prometheus+: {
          ingress+: {
            enabled: true,
            hosts: [
              'prometheus-edge.gudo11y.local',
            ],
          },
          prometheusSpec+: {
            remoteWrite: [
              {
                url: 'http://mimir-nginx.monitoring.svc.cluster.local/api/v1/push',
                writeRelabelConfigs: [
                  {
                    sourceLabels: ['__name__'],
                    regex: '.*',
                    action: 'keep',
                  },
                ],
              },
            ],
          },
        },
        grafana+: {
          enabled: true,
          ingress+: {
            enabled: true,
            hosts: [
              common.central.grafana_domain,
            ],
          },
          // Disable authentication entirely
          'grafana.ini'+: {
            'auth.anonymous'+: {
              enabled: true,
              org_role: 'Admin',
            },
            auth+: {
              disable_login_form: true,
            },
          },
          additionalDataSources: [
            {
              name: 'Loki',
              type: 'loki',
              access: 'proxy',
              url: 'http://loki-gateway.%s.svc.cluster.local' % common.namespace,
              isDefault: false,
              jsonData: {
                maxLines: 1000,
              },
            },
            {
              name: 'Tempo',
              type: 'tempo',
              access: 'proxy',
              url: 'http://tempo.%s.svc.cluster.local:3100' % common.namespace,
              isDefault: false,
            },
          ],
        },
      },
    }
  ),
}
