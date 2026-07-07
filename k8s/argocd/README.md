# Argo CD Deployment

This directory contains two Argo CD deployment styles for the same stack:

- `app-of-apps/`: a root `Application` that owns child `Application` resources.
- `applicationsets/`: an `ApplicationSet` example that generates the same app resources.

Both styles are split by environment:

- `dev/` deploys the development overlay.
- `prod/` deploys the production overlay.

The sync order is:

1. `namespaces` with sync wave `-1`
2. `platform-helmfile` with sync wave `0`
3. `platform-grafana-provisioning` with sync wave `1`
4. the selected `springservice` overlay with sync wave `2`

The `platform-helmfile` application expects an Argo CD Helmfile config-management plugin named `helmfile`. Without that plugin, deploy the platform with `helmfile` from your workstation and let Argo CD manage the app overlays plus Grafana provisioning ConfigMaps.

## Prerequisites

Install local tools:

```powershell
winget install Kubernetes.kubectl
winget install k3d.k3d
winget install Helm.Helm
winget install Argo.ArgoCD
```

Install Helmfile if you want to deploy the platform from your workstation:

```powershell
winget install helmfile.helmfile
```

## Create a k3d Cluster with Traefik Ingress

k3s includes Traefik by default. This creates a k3d cluster and exposes Traefik through the k3d load balancer on local ports 80 and 443.

```powershell
k3d cluster create springservice `
  --servers 1 `
  --agents 2 `
  --port "80:80@loadbalancer" `
  --port "443:443@loadbalancer"
```

Confirm the cluster and ingress controller:

```powershell
kubectl cluster-info
kubectl get pods -n kube-system -l app.kubernetes.io/name=traefik
kubectl get ingressclass
```

## Install Argo CD

```powershell
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s
```

Get the initial admin password:

```powershell
argocd admin initial-password -n argocd
```

Port-forward the Argo CD UI:

```powershell
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Log in:

```powershell
argocd login localhost:8080 --username admin --password <password> --insecure
```

## Deploy with App of Apps

From the repository root:

```powershell
kubectl apply -k springservice/k8s/argocd/app-of-apps/dev
```

The dev root app is `springservice-dev-root`. You can sync it from the UI or CLI:

```powershell
argocd app sync springservice-dev-root
argocd app wait springservice-dev-root --health --timeout 600
```

For production:

```powershell
kubectl apply -k springservice/k8s/argocd/app-of-apps/prod
argocd app sync springservice-prod-root
argocd app wait springservice-prod-root --health --timeout 600
```

## Deploy with ApplicationSets

Use this instead of the app-of-apps example when you want generated `Application` resources:

```powershell
kubectl apply -k springservice/k8s/argocd/applicationsets/dev
```

For production:

```powershell
kubectl apply -k springservice/k8s/argocd/applicationsets/prod
```

Then inspect the generated apps:

```powershell
argocd app list
kubectl get applications -n argocd
```

## Deploy the Platform Without the Argo CD Helmfile Plugin

If your Argo CD instance does not have a Helmfile plugin, deploy the observability platform directly:

```powershell
cd springservice/k8s/platform/helmfile
helmfile -e dev apply
```

Then let Argo CD manage the Grafana provisioning ConfigMaps:

```powershell
kubectl apply -k springservice/k8s/platform/helmfile/observability/prometheus-stack/grafana
```

## Local Hostnames

Add the ingress hostnames from the environment values to your hosts file, pointing to `127.0.0.1`. For development these include:

```text
127.0.0.1 grafana-dev-local.com
127.0.0.1 prometheus-dev-local.com
```

Check the rendered ingress resources:

```powershell
kubectl get ingress -A
```
