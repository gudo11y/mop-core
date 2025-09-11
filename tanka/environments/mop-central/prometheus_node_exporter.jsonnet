local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local helm = tanka.helm.new(std.thisFile);
local common = import 'common.libsonnet';

{
  prometheus_node_exporter: helm.template(
    name='prometheus-node-exporter',
    chart='./charts/prometheus-node-exporter',
    conf={
      namespace: common.namespace,
      values+: {

      },
    }
  ),
}
