local tanka = import "github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet";
local helm = tanka.helm.new(std.thisFile);
local common = import 'common.libsonnet';

{
    backstage: helm.template(
        name="backstage",
        chart='./charts/backstage',
        conf={
            namespace: 'monitoring',
            values: {

            }
        })
}