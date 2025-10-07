local alloy = import 'alloy.jsonnet';
local alloy_operator = import 'alloy_operator.jsonnet';
local common = import 'common.libsonnet';
local config = import 'config.jsonnet';
local eso = import 'eso.jsonnet';
local kps = import 'kps.jsonnet';
local linkerd = import 'linkerd.jsonnet';
local loki = import 'loki.jsonnet';
local tempo = import 'tempo.jsonnet';

{
  config: config.config,
  eso: eso.eso,
  kps: kps.kps,
  loki: loki.loki,
  alloy_operator: alloy_operator.alloy_operator,
  // alloy: alloy.alloy,
  // tempo: tempo.tempo,
  linkerdCRDs: linkerd.linkerdCRDs,
  linkerdControlPlane: linkerd.linkerdControlPlane,
}
