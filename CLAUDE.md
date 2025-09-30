# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**mop-core** (Managed Observability Platform - Core) is a Kubernetes observability platform infrastructure project that deploys a complete observability stack using infrastructure-as-code. It's built with Tanka (Jsonnet + Kubernetes) and provides three deployment environments: central, cloud, and edge.

## Common Development Commands

### Tanka Operations
```bash
# Apply configuration to specific environment
tk apply tanka/environments/mop-edge

# Show generated manifests without applying
tk show tanka/environments/mop-edge

# Validate Jsonnet and Kubernetes manifests
tk validate tanka/environments/mop-edge

# Update Jsonnet dependencies
cd tanka && jb update

# Vendor Helm charts for specific environment
cd tanka/environments/mop-edge && tk tool charts vendor
```

### Tilt Local Development
```bash
# Start local development environment
tilt up

# Run with specific environment
tilt up -- --env mop-edge

# Setup Tilt environment (run once)
./scripts/tilt_setup.sh

# Build mop-edge environment
./scripts/tilt_build.sh
```

### Testing and Validation
```bash
# Validate all environments
for env in mop-central mop-cloud mop-edge; do
  tk validate tanka/environments/$env
done

# Generate and inspect manifests
tk show tanka/environments/mop-edge | kubectl apply --dry-run=client -f -
```

## Architecture and Structure

### Core Technologies
- **Tanka**: Primary infrastructure-as-code tool using Jsonnet templating
- **Helm Charts**: For packaging observability applications
- **Tilt**: Local development workflow automation targeting minikube
- **Kubernetes**: Deployment platform (configured for minikube context)

### Observability Stack Components
The platform deploys: Prometheus, Grafana, Loki, Mimir, Tempo, Alloy/Alloy Operator, and optionally Backstage.

### Three-Tier Environment Model
- **mop-central**: Central management environment
- **mop-cloud**: Cloud environment configuration
- **mop-edge**: Edge environment configuration

Each environment is a separate Tanka environment with its own:
- `spec.json` (Tanka environment specification)
- `chartfile.yaml` (Helm chart dependencies)
- `main.jsonnet` (Environment-specific configuration)

### Key Directory Structure
```
tanka/
├── lib/                     # Shared Jsonnet libraries
│   ├── common.libsonnet     # Common configurations and defaults
│   ├── k.libsonnet         # Kubernetes utilities
│   └── utils.libsonnet     # Utility functions
├── environments/           # Environment-specific configurations
└── vendor/                # Vendored Jsonnet dependencies
```

### Dependency Management
- **jsonnetfile.json**: Manages Jsonnet library dependencies from Grafana Labs
- **chartfile.yaml**: Per-environment Helm chart dependencies
- **vendor/**: Jsonnet dependencies via `jb` (jsonnet-bundler)
- Charts are vendored per environment using `tk tool charts vendor`

### Development Workflow
1. Use Tilt for local development with live reloading
2. Modify Jsonnet configurations in `tanka/environments/`
3. Shared logic goes in `tanka/lib/` Libsonnet files
4. Validate changes with `tk validate` before applying
5. Environment changes are automatically detected by Tilt

### Configuration Patterns
- Environment-specific values are parameterized in `main.jsonnet`
- Common configurations are abstracted in `tanka/lib/common.libsonnet`
- Kubernetes utilities are available via `tanka/lib/k.libsonnet`
- All environments target minikube context by default