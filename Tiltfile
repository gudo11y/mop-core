# --- basics ---
allow_k8s_contexts('minikube')  # or your context

# import os

# Pick Tanka env via env var: TK_ENV=dev tilt up
# tk_env = os.getenv('TK_ENV', 'dev')
tk_env = os.getenv('TK_ENV', 'mop-edge')

# Where to write rendered manifests for Tilt to pick up
out_file = './.tilt/{tk_env}.yaml'.format(tk_env=tk_env)

# Files that should trigger re-render/apply when changed
jsonnet_deps = [
#   './tanka/environments/{tk_env}/**/*.jsonnet'.format(tk_env=tk_env),
#   './tanka/environments/{tk_env}/**/*.libsonnet'.format(tk_env=tk_env),
  './tanka/environments/**/*.jsonnet',
  './tanka/environments/**/*.libsonnet',
  './tanka/lib/**/*.libsonnet',
  './tanka/lib/**/*.jsonnet',
#   './tanka/vendor/**',
]

# # 1) Generate YAML from Tanka
# x = local_resource(
#   name='tanka-render',
#   cmd='mkdir -p .tilt && tk show ./tanka/environments/{tk_env} --dangerous-allow-redirect > {out_file}'.format(tk_env=tk_env, out_file=out_file),
#   deps=jsonnet_deps,
#   labels=['tanka'],
# )

local(
    command='tk show ./tanka/environments/{tk_env} --dangerous-allow-redirect > {out_file}'.format(tk_env=tk_env, out_file=out_file),
)

# k8s_custom_deploy(
#   name='tanka-apply',
#   apply_cmd='tk apply ./tanka/environments/{tk_env} --force --auto-approve always'.format(tk_env=tk_env),
# #   delete_cmd='tk delete ./tanka/environments/{tk_env} --auto-approve always'.format(tk_env=tk_env),
#   delete_cmd='tk prune ./tanka/environments/{tk_env} '.format(tk_env=tk_env),
#   deps=jsonnet_deps,
# )


k8s_yaml(out_file)

# (optional) group or tweak resources (port-forwards, namespaces, etc.)
# k8s_resource('backend', port_forwards=['8080:8080'])
# k8s_resource('frontend', port_forwards=['3000:80'])

# Make render run automatically when deps change
# trigger_mode(AUTO)  # default; explicit for clarity