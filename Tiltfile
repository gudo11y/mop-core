# --- basics ---
allow_k8s_contexts(['minikube', 'k3d-prod', 'orbstack'])


# Pick Tanka env via env var: TK_ENV=dev tilt up
tk_env = os.getenv('TK_ENV', 'mop-edge')

# Where to write rendered manifests for Tilt to pick up
out_file = '.tilt/{tk_env}.yaml'.format(tk_env=tk_env)

# Files that should trigger re-render/apply when changed
jsonnet_deps = [
  './tanka/environments/{tk_env}/'.format(tk_env=tk_env),
  './tanka/lib/',
]

local_resource(
    name='setup',
    cmd= 'scripts/tilt_setup.sh'
)

# Install kube-prometheus-stack CRDs separately (for mop-edge and mop-cloud)
# These CRDs have annotations that are too large for kubectl apply, so we install them with kubectl create --server-side
if tk_env in ['mop-edge', 'mop-cloud']:
    local_resource(
        name='install-kps-crds',
        cmd='kubectl apply --server-side -f tanka/environments/{tk_env}/charts/kube-prometheus-stack/charts/crds/crds/ || true'.format(tk_env=tk_env),
        resource_deps=['setup'],
        auto_init=True,
        trigger_mode=TRIGGER_MODE_MANUAL,
        labels=['kubernetes'],
    )
    tk_apply_deps = ['setup', 'install-kps-crds']
else:
    tk_apply_deps = ['setup']

# Generate Tanka manifests and load them into Tilt
local_resource(
    name='tk-render',
    cmd='mkdir -p .tilt && tk show ./tanka/environments/{tk_env} --dangerous-allow-redirect > {out_file}'.format(tk_env=tk_env, out_file=out_file),
    deps=jsonnet_deps,
    resource_deps=tk_apply_deps,
    auto_init=True,
    trigger_mode=TRIGGER_MODE_AUTO,
    labels=['kubernetes'],
)

# Load the generated YAML so Tilt tracks the resources
k8s_yaml(out_file)

# Watch for changes in the generated YAML file to trigger reapplication
watch_file(out_file)

# --- UI links for services ---
# Add Grafana to Tilt UI with port forward and link
if tk_env == 'mop-central':
    k8s_resource(
        workload='grafana',
        port_forwards='3001:80',
        links=[
            link('http://localhost:3001', 'Grafana (local)'),
            link('http://grafana.gudo11y.local', 'Grafana (ingress)'),
        ],
        labels=['observability'],
    )
else:
    k8s_resource(
        workload='kube-prometheus-stack-grafana',
        port_forwards='3001:80',
        links=[
            link('http://localhost:3001', 'Grafana (local)'),
            link('http://grafana.gudo11y.local', 'Grafana (ingress)'),
        ],
        labels=['observability'],
    )

# Add Backstage to Tilt UI (only in mop-central)
if tk_env == 'mop-central':
    k8s_resource(
        workload='backstage',
        port_forwards='7007:7007',
        links=[
            link('http://localhost:7007', 'Backstage'),
        ],
        labels=['platform'],
    )
