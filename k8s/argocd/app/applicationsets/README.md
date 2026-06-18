# ApplicationSets Pattern

## Overview

ApplicationSets leverage templating and generators to dynamically generate cluster resources from a single control manifest. This approach provides:

- **Dynamic generation**: One control manifest templates infrastructure patterns across infinite targets.
- **DRY principle**: Eliminates code duplication - no separate dev/prod files needed
- **Phased orchestration**: Separates tenancy controls (AppProject) from workload configurations (Applications).
- **Linear scaling**: Onboards additional cluster targets by modifying list items instead of replicating files.

## Structure

```
applicationsets/
├── app-projects.yaml                # Phase 1: Dynamic AppProject generator
├── app-deployments.yaml             # Phase 2: Dynamic workload ApplicationSet
└── readME.md                        # 
```

## How It Works

### Deployment Flow

1. **Deploy Project Infrastructure**
   ```bash
   kubectl apply -f applicationsets/app-projects.yaml
   ```
   This initializes an ApplicationSet that dynamically spawns isolated AppProject boundaries directly inside the cluster.

2. **Deploy Workload Matrix**
   ```bash
   kubectl apply -f applicationsets/app-deployments.yaml
   ```
   This registers the matrix-driven workload configurations. Because Phase 1 completed first, child workloads instantly map to their pre-existing environment sandboxes without permission race conditions.
3. **Orchestrated Output Lifecycle**
   The app-deployments.yaml manifest combines your environments and component matrices to output targeted deployments automatically:
   - springservice-dev-app (Deploys tracking path k8s/overlays/dev into the development namespace)
   - springservice-prod-app (Deploys tracking path k8s/overlays/prod into the production namespace)

### Key Features

- **Matrix Multiplication**: Evaluates environment parameters against structural application layers natively.
- **Strict Tenancy Scoping**: Bypasses the cluster's default namespace; each workspace explicitly references springservice-project-{{env}}.
- **Go Template Injection**: Safely evaluates conditions and structures across unified parameter definitions.
- **Zero-Braid Validation**: Minimizes directory footprints down to a single clean file repository.


## Deployment

### Deploy All Environments (Dev & Prod)
```bash
# Step 1: Establish environment-specific cluster authorization projects
kubectl apply -f applicationsets/app-projects.yaml

# Step 2: Deploy operational workload matrix
kubectl apply -f applicationsets/app-deployments.yaml
```

This single command deploys applicationsets for **both dev and prod** automatically!

### View Generated Applications
```bash
argocd app list
```

### Sync Applications
```bash
argocd app sync springservice-dev-app
argocd app sync springservice-prod-app
```

## Generated Applications

### Automatically Created (from single springservice-apps ApplicationSet)
- `springservice-project-dev` (Controls destination access for the development namespace)
- `springservice-project-prod` (Controls destination access for the production namespace)
- `springservice-dev-app`  → References springservice-project-dev (k8s/overlays/dev → development namespace)
- `springservice-prod-app` → References springservice-project-prod (k8s/overlays/prod → production namespace)


## Benefits vs Disadvantages

### Benefits
✅ **DRY Principle**: Single template generates 4 applications for dev + prod  
✅ **Matrix Generators**: Create all environment combinations automatically  
✅ **No Folder Duplication**: One definition works for all environments  
✅ **Easy to Scale**: Add new environments by extending the list generator  
✅ **Less Maintenance**: Fix bugs once, affects all environments  
✅ **Native ArgoCD**: No external tools needed  

### Disadvantages
❌ Matrix generators require understanding template logic  
❌ Debugging generated applications needs knowledge of generator parameters  
❌ Template variables can become complex in large deployments  

