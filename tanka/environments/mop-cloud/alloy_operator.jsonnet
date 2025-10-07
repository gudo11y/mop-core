local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local helm = tanka.helm.new(std.thisFile);
local common = import 'common.libsonnet';

{
  alloy_operator: helm.template(
    name='alloy-operator',
    chart='./charts/alloy-operator',
    conf={
      namespace: common.namespace,
      values+: {

      },
    }
  ),
}
