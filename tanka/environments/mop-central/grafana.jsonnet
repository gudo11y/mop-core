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

      },
    }
  ),
}
