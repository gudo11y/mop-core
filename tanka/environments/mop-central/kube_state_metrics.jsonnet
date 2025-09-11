local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local helm = tanka.helm.new(std.thisFile);
local common = import 'common.libsonnet';

{
  kube_state_metrics: helm.template(
    name='kube-state-metrics',
    chart='./charts/kube-state-metrics',
    conf={
      namespace: common.namespace,
      values+: {

      },
    }
  ),
}
