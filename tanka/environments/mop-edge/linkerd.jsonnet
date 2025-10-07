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

  // Linkerd Control Plane - Edge environment configuration
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

        // Resource constraints for edge deployments
        // Optimize for resource-constrained environments
        // proxy: {
        //   resources: {
        //     cpu: {
        //       request: '50m',
        //       limit: '500m',
        //     },
        //     memory: {
        //       request: '10Mi',
        //       limit: '100Mi',
        //     },
        //   },
        // },

        // Single replica mode for edge (adjust based on requirements)
        // controllerReplicas: 1,

        // Proxy injector configuration
        proxyInjector: {
          // Automatically inject Linkerd proxy into annotated namespaces
        },

        // Multi-cluster configuration for edge-to-cloud connectivity
        // gateway: {
        //   enabled: true,
        //   serviceType: 'NodePort',  // Use NodePort for edge environments
        //   port: 4143,
        // },
      },
    }
  ),

  // Optional: Linkerd Viz for local metrics (lightweight for edge)
  // linkerdViz: helm.template(
  //   name='linkerd-viz',
  //   chart='./charts/linkerd-viz',
  //   conf={
  //     namespace: 'linkerd-viz',
  //     values: {
  //       prometheus: {
  //         enabled: false,
  //         url: 'http://prometheus.monitoring:9090',
  //       },
  //       tap: {
  //         resources: {
  //           cpu: {
  //             request: '50m',
  //             limit: '500m',
  //           },
  //         },
  //       },
  //     },
  //   }
  // ),

  // Edge-specific features:
  // 1. Optimize for resource-constrained environments (lower CPU/memory)
  // 2. Use NodePort services instead of LoadBalancer
  // 3. Enable multi-cluster for edge-to-cloud federation
  // 4. Consider disabling Viz dashboard to save resources
  // 5. Use remote Prometheus/Grafana from central/cloud environments
  // 6. Enable circuit breaking for unreliable network connections
}
