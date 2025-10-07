local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local helm = tanka.helm.new(std.thisFile);
local common = import 'common.libsonnet';

{
  // Linkerd CRDs - Must be installed before control plane
  linkerdCRDs: helm.template(
    name='linkerd-crds',
    chart='./charts/linkerd-crds',
    conf={
      namespace: 'linkerd',
      values: {},
    }
  ),

  // Linkerd Control Plane - Basic configuration
  linkerdControlPlane: helm.template(
    name='linkerd-control-plane',
    chart='./charts/linkerd-control-plane',
    conf={
      namespace: 'linkerd',
      values: {
        // Identity configuration - certificates for mTLS
        identity: {
          issuer: {
            scheme: 'kubernetes.io/tls',
          },
        },

        // High availability mode (commented out - enable for production)
        // controllerReplicas: 3,
        // enablePodAntiAffinity: true,

        // Resource limits
        // proxy: {
        //   resources: {
        //     cpu: {
        //       request: '100m',
        //       limit: '1',
        //     },
        //     memory: {
        //       request: '20Mi',
        //       limit: '250Mi',
        //     },
        //   },
        // },

        // Enable Linkerd Viz extension for dashboard and metrics
        // Install separately with linkerd-viz chart

        // Proxy injector configuration
        proxyInjector: {
          // Automatically inject Linkerd proxy into annotated namespaces
          // Add annotation: linkerd.io/inject: enabled
        },

        // mTLS settings
        // identity: {
        //   issuer: {
        //     crtExpiry: '8760h',  // 1 year
        //     issuanceLifetime: '86400s',  // 24 hours
        //   },
        // },
      },
    }
  ),

  // Optional: Linkerd Viz for metrics and dashboard
  // Uncomment to enable visualization and Grafana integration
  // linkerdViz: helm.template(
  //   name='linkerd-viz',
  //   chart='./charts/linkerd-viz',
  //   conf={
  //     namespace: 'linkerd-viz',
  //     values: {
  //       // Use external Prometheus (from mop-core)
  //       prometheus: {
  //         enabled: false,
  //         url: 'http://prometheus.monitoring:9090',
  //       },
  //       // Grafana integration
  //       grafana: {
  //         enabled: false,
  //         url: 'http://grafana.monitoring:3000',
  //       },
  //       dashboard: {
  //         enabled: true,
  //       },
  //     },
  //   }
  // ),

  // Optional: Service Mesh Interface (SMI) for traffic splitting
  // linkerdSMI: helm.template(
  //   name='linkerd-smi',
  //   chart='./charts/linkerd-smi',
  //   conf={
  //     namespace: 'linkerd',
  //     values: {},
  //   }
  // ),

  // Optional: Jaeger extension for distributed tracing
  // Integrate with Tempo from mop-core
  // linkerdJaeger: helm.template(
  //   name='linkerd-jaeger',
  //   chart='./charts/linkerd-jaeger',
  //   conf={
  //     namespace: 'linkerd-jaeger',
  //     values: {
  //       collector: {
  //         // Forward traces to Tempo
  //         externalUrl: 'http://tempo.monitoring:9411',
  //       },
  //     },
  //   }
  // ),

  // Optional: Multi-cluster support
  // linkerdMulticluster: helm.template(
  //   name='linkerd-multicluster',
  //   chart='./charts/linkerd-multicluster',
  //   conf={
  //     namespace: 'linkerd-multicluster',
  //     values: {},
  //   }
  // ),

  // Tips for using Linkerd:
  // 1. Inject proxy into a namespace: kubectl annotate namespace <ns> linkerd.io/inject=enabled
  // 2. Check mesh status: linkerd check
  // 3. View service mesh dashboard: linkerd viz dashboard
  // 4. Enable traffic splitting with SMI for canary deployments
  // 5. Monitor golden metrics (success rate, RPS, latency) via Linkerd Viz
  // 6. Use policy resources for fine-grained authorization
}
