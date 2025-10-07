local alloy_operator = import 'alloy_operator.jsonnet';
local backstage = import 'backstage.jsonnet';
local common = import 'common.libsonnet';
local config = import 'config.jsonnet';
local eso = import 'eso.jsonnet';
local grafana = import 'grafana.jsonnet';
local linkerd = import 'linkerd.jsonnet';
local loki = import 'loki.jsonnet';
local mimir = import 'mimir.jsonnet';
local prometheus = import 'prometheus.jsonnet';
local tempo = import 'tempo.jsonnet';

{
  config: config.config,
  backstage: backstage.backstage,
  eso: eso.eso,
  grafana: grafana.grafana,
  prometheus: prometheus.prometheus,
  loki: loki.loki,
  mimir: mimir.mimir,
  tempo: tempo.tempo,
  alloy_operator: alloy_operator.alloy_operator,
  linkerdCRDs: linkerd.linkerdCRDs,
  linkerdControlPlane: linkerd.linkerdControlPlane,
}
