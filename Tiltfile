# --- basics ---
allow_k8s_contexts('minikube')  # or your context

import os

# Pick Tanka env via env var: TK_ENV=dev tilt up
tk_env = os.getenv('TK_ENV', 'dev')

# Where to write rendered manifests for Tilt to pick up
out_file = f'./.tilt/tanka-{tk_env}.yaml'

# Files that should trigger re-render/apply when changed
jsonnet_deps = [
  'environments/{env}/**/*.jsonnet'.format(env=tk_env),
  'environments/{env}/**/*.libsonnet'.format(env=tk_env),
  'lib/**/*.libsonnet',
  'lib/**/*.jsonnet',
  'vendor/**',
]

# 1) Generate YAML from Tanka
local_resource(
  name='tanka-render',
  cmd=f'mkdir -p .tilt && tk show environments/{tk_env} > {out_file}',
  deps=jsonnet_deps,
  labels=['tanka'],
)

# 2) Ask Tilt to load/apply that YAML
k8s_yaml(out_file)

# (optional) group or tweak resources (port-forwards, namespaces, etc.)
# k8s_resource('backend', port_forwards=['8080:8080'])
# k8s_resource('frontend', port_forwards=['3000:80'])

# Make render run automatically when deps change
trigger_mode(AUTO)  # default; explicit for clarity