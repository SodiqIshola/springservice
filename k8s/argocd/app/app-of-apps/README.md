# App-of-Apps Pattern (Version 1)

## Overview

This implementation of the App-of-Apps pattern enforces a strict decoupling of security and workloads by managing AppProjects and Applications in independent lifecycles. This approach provides:

- **Security Isolation**:  Projects (cluster-level permissions) are managed independently from applications (workload-level deployments).
- **Two-Phase Bootstrapping**: Guarantees that permission boundaries exist in the cluster before any application manifests attempt to mount them.
- **Environment Isolation:**: Tailors cluster target destinations via environment-specific Kustomize overlays.

## Structure

```
app-of-apps-1/
├── app-deployment/
│   ├── base/
│   │   ├── kustomization.yaml       # Base application references
│   │   ├── root.yaml                # Root application template
│   │   └── springservice.yaml       # Service application template
│   └── overlays/
│       ├── dev/
│       │   └── kustomization.yaml   # Dev application patches
│       └── prod/
│           └── kustomization.yaml   # Prod application patches
└── app-projects/
    ├── base/
    │   ├── kustomization.yaml       # Base project references
    │   └── springservice-project.yaml # AppProject template
    └── overlays/
        ├── dev/
        │   └── kustomization.yaml   # Dev project patches
        └── prod/
            └── kustomization.yaml   # Prod project patches
```

## How It Works

### Intended Deployment Flow

1. ** Apply Cluster Permissions First**
   ```bash
   kubectl apply -k k8s/argocd/app-of-apps-1/app-projects/overlays/dev
   ```
   This registers the environment-specific AppProject directly into the cluster via native Kubernetes.

2. **Apply the Application Controller Stack**
   ```bash
   kubectl apply -k k8s/argocd/app-of-apps-1/app-deployment/overlays/dev
   ```
   This creates the parent Root Application, which instantly finds the pre-existing project boundary and spins up child apps.

3. **Root Application Configuration** (`springservice-root-dev`)
   - **Scoped to Custom Project:** Deployed directly into springservice-project-{{env}} instead of the default project. This ensures strict tenancy and prevents the root application from tracking or modifying resources outside its designated environment.
   - **Git Targeting:** Points directly to the app-deployment/overlays/<env> directory in Git to discover and track child workloads.
   - **Self-Management Capability:** The custom AppProject must be explicitly configured to allow the Application kind within its resource allowlist so the Root Application can safely manage its child apps.

4. **Child Applications**
   - `springservice-dev`: Deploys the main application (wave: 1)

### Key Features

- **Separated Concerns**: Projects and applications are in different directories
- **Kustomize Overlays**: Environment-specific patches for both projects and apps
- **Sync Waves**: Controls deployment order (wave 1 for applications)
- **Default Project**: Root application uses `default` project to avoid errors
- **Automated Syncing**: Changes in Git automatically sync to cluster


## Deployment (When Fixed)

### Deploy Dev Environment
```bash
# 1. Deploy projects first
kubectl apply -k k8s/argocd/app-of-apps-1/app-projects/overlays/dev

# 2. Deploy applications
kubectl apply -k k8s/argocd/app-of-apps-1/app-deployment/overlays/dev
```

### Deploy Prod Environment
```bash
# 1. Deploy projects first
kubectl apply -k k8s/argocd/app-of-apps-1/app-projects/overlays/prod

# 2. Deploy applications
kubectl apply -k k8s/argocd/app-of-apps-1/app-deployment/overlays/prod
```

### View Applications
```bash
argocd app list
```

### Sync Applications
```bash
argocd app sync springservice-root-dev
```

## Benefits vs Disadvantages

### Benefits
✅ Clear separation between projects and applications
✅ Hierarchical management with parent-child relationships
✅ Wave-based deployment control
✅ Environment-specific configurations
✅ Root uses default project (no permission errors)

### Disadvantages
❌ More complex directory structure
❌ Requires two separate deployments (projects + apps)
❌ Manual Application creation via Kustomize patches
❌ Limited templating capabilities
❌ Currently has configuration issues

