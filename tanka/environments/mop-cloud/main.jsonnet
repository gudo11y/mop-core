local common = import 'common.libsonnet';
local config = import 'config.libsonnet';
local alloy = import 'alloy.jsonnet';
local kps = import 'kps.jsonnet';
local loki = import 'loki.jsonnet';
local tempo = import 'tempo.jsonnet';

{
    config: config.config,
    kps: kps.kps,
    loki: loki.loki,
    alloy: alloy.alloy,
    tempo: tempo.tempo,
}
