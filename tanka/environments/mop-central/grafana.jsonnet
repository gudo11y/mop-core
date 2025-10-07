local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local helm = tanka.helm.new(std.thisFile);
local common = import 'common.libsonnet';

{
  grafana: helm.template(
    name='grafana',
    chart='./charts/grafana',
    conf={
      namespace: common.namespace,
      values+: {
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
        datasources: {
          'datasources.yaml': {
            apiVersion: 1,
            datasources: [
              {
                name: 'Prometheus',
                type: 'prometheus',
                access: 'proxy',
                url: 'http://prometheus-server.monitoring.svc.cluster.local',
                isDefault: true,
              },
              {
                name: 'Loki',
                type: 'loki',
                access: 'proxy',
                url: 'http://loki-gateway.monitoring.svc.cluster.local',
                isDefault: false,
                jsonData: {
                  maxLines: 1000,
                },
              },
              {
                name: 'Tempo',
                type: 'tempo',
                access: 'proxy',
                url: 'http://tempo-query-frontend.monitoring.svc.cluster.local:3100',
                isDefault: false,
              },
              {
                name: 'Mimir',
                type: 'prometheus',
                access: 'proxy',
                url: 'http://mimir-query-frontend.monitoring.svc.cluster.local:8080/prometheus',
                isDefault: false,
              },
            ],
          },
        },
      },
    }
  ),
}
