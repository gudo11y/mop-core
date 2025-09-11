local alloy_operator = import 'alloy-operator.jsonnet';
local backstage = import 'backstage.jsonnet';
local common = import 'common.libsonnet';
local config = import 'config.libsonnet';
local grafana = import 'grafana.jsonnet';
local kube_state_metrics = import 'kube-state-metrics.jsonnet';
local prometheus_node_exporter = import 'prometheus-node-exporter.jsonnet';
local prometheus = import 'prometheus.jsonnet';
local loki = import 'loki.jsonnet';
local mimir = import 'mimir.jsonnet';
local tempo = import 'tempo.jsonnet';

{
  config: config.config,
  backstage: backstage.backstage,
  grafana: grafana.grafana,
  kube_state_metrics: kube_state_metrics.kube_state_metrics,
  prometheus_node_exporter: prometheus_node_exporter.prometheus_node_exporter,
  prometheus: prometheus.prometheus,
  loki: loki.loki,
  mimir: mimir.mimir,
  tempo: tempo.tempo,
  alloy_operator: alloy_operator.alloy_operator,
}
