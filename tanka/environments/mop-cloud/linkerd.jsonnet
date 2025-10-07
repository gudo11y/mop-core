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

  // Linkerd Control Plane - Cloud environment configuration
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

        // High availability mode for cloud environments
        // Uncomment for production deployments
        // controllerReplicas: 3,
        // enablePodAntiAffinity: true,
        // enablePodDisruptionBudget: true,

        // Proxy configuration
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

        // Proxy injector configuration
        proxyInjector: {
          // Automatically inject Linkerd proxy into annotated namespaces
        },

        // Multi-cluster gateway configuration (for cloud-to-edge communication)
        // gateway: {
        //   enabled: true,
        //   serviceType: 'LoadBalancer',
        //   port: 4143,
        // },
      },
    }
  ),

  // Optional: Linkerd Viz for metrics and dashboard
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
  //       grafana: {
  //         enabled: false,
  //         url: 'http://grafana.monitoring:3000',
  //       },
  //     },
  //   }
  // ),

  // Cloud-specific features:
  // 1. Enable multi-cluster for cloud-to-edge mesh federation
  // 2. Configure ingress controllers with Linkerd annotation
  // 3. Use LoadBalancer services for gateway exposure
  // 4. Integrate with cloud provider's certificate management
  // 5. Enable policy enforcement for zero-trust networking
}
