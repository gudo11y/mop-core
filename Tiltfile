# --- basics ---
allow_k8s_contexts('minikube')  # or your context


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


local_resource(
    name='tk-show',
    cmd='tk show ./tanka/environments/{tk_env} --dangerous-allow-redirect > {out_file}'.format(tk_env=tk_env, out_file=out_file),
    deps=jsonnet_deps,
)

k8s_yaml(out_file)

# --- links to services ---
link('http://grafana.gudo11y.local', 'Grafana Dashboard')
