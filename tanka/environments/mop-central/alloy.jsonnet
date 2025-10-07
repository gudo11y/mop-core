local k = import 'k.libsonnet';
local common = import 'common.libsonnet';

local configMap = k.core.v1.configMap;
local alloy = {
  apiVersion: 'collectors.grafana.com/v1alpha1',
  kind: 'Alloy',
  metadata: {
    name: 'alloy-metrics',
    namespace: common.namespace,
  },
  spec: {
    // Alloy configuration
    image: {
      repository: 'grafana/alloy',
      tag: 'latest',
    },
    alloy: {
      configMap: {
        content: |||
          // Scrape node exporter metrics
          prometheus.scrape "node_exporter" {
            targets = [
              {
                "__address__" = "kube-prometheus-stack-prometheus-node-exporter.mop.svc.cluster.local:9100",
              },
            ]
            forward_to = [prometheus.remote_write.mimir.receiver]

            scrape_interval = "15s"
          }

          // Remote write to Mimir
          prometheus.remote_write "mimir" {
            endpoint {
              url = "http://mimir-nginx.monitoring.svc.cluster.local/api/v1/push"

              queue_config {
                capacity = 10000
                max_shards = 10
                min_shards = 1
                max_samples_per_send = 5000
                batch_send_deadline = "5s"
                min_backoff = "30ms"
                max_backoff = "5s"
              }
            }
          }
        |||,
      },
    },
  },
};

{
  alloy: alloy,
}
