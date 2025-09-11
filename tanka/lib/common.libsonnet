{
  namespace:: 'mop',

  defaults:: {
    kps:: {
      values:: {
        nameOverride: 'kps',
        defaultRules+: {
          rules+:
            {
              alertmanager: true,
              etcd: true,
              configReloaders: true,
              general: true,
              k8sContainerCpuUsageSecondsTotal: true,
              k8sContainerMemoryCache: true,
              k8sContainerMemoryRss: true,
              k8sContainerMemorySwap: true,
              k8sContainerResource: true,
              k8sContainerMemoryWorkingSetBytes: true,
              k8sPodOwner: true,
              kubeApiserverAvailability: true,
              kubeApiserverBurnrate: true,
              kubeApiserverHistogram: true,
              kubeApiserverSlos: true,
              kubeControllerManager: true,
              kubelet: true,
              kubeProxy: true,
              kubePrometheusGeneral: true,
              kubePrometheusNodeRecording: true,
              kubernetesApps: true,
              kubernetesResources: true,
              kubernetesStorage: true,
              kubernetesSystem: true,
              kubeSchedulerAlerting: true,
              kubeSchedulerRecording: true,
              kubeStateMetrics: true,
              network: true,
              node: true,
              nodeExporterAlerting: true,
              nodeExporterRecording: true,
              prometheus: true,
              prometheusOperator: true,
              windows: true,


            },
        },
        alertmanager+: {
          enabled: true,
        },
        grafana+: {
          enabled: true,
        },
        'prometheus-node-exporter'+: {
          enabled: true,
        },
        prometheusOperator+: {
          enabled: true,
        },
        prometheus+: {
          agentMode: false,
          ingress+: {
            enabled: true,
            hosts: [
              'prometheus.gudo11y.local',
            ],
          },

          prometheusSpec+: {
            enableAdminAPI: true,

            ruleNamespaceSelector: '',
            ruleSelectorNilUsesHelmValues: true,
            ruleSelector: '',

            serviceMonitorSelectorNilUsesHelmValues: true,
            serviceMonitorSelector: '',
            serviceMonitorNamespaceSelector: '',

            podMonitorSelectorNilUsesHelmValues: true,
            podMonitorSelector: '',
            podMonitorNamespaceSelector: '',

            probeSelectorNilUsesHelmValues: true,
            probeSelector: '',
            probeNamespaceSelector: '',

            scrapeConfigSelectorNilUsesHelmValues: true,
            scrapeConfigSelector: '',
            scrapeConfigNamespaceSelector: '',

            retention: '2d',
          },
        },
      },
    },

    mimir:: {

    },

    loki:: {

    },

    alloy:: {

    },

    tempo:: {

    },

  },

  central:: {
    grafana_domain:: 'grafana.gudo11y.local',

  },

  cloud:: {

  },

  edge:: {

  },
}
