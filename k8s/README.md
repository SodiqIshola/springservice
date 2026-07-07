# Kubernetes Configuration

This directory contains Kubernetes manifests and configurations for deploying the Spring microservices application using Kustomize.

## Directory Structure

### `namespaces/`
Contains namespace definitions for `development`, `production`, and `monitoring`. Deploy this before the application base or overlays.

### `base/`
Contains the base Kubernetes resources that are common across all environments. This includes:
- **Data Services**: PostgreSQL database and pgAdmin for database management.
- **Messaging Services**: RabbitMQ, ZooKeeper, Kafka, and Kafka UI for message queuing and event streaming.
- **Applications**: The Spring Boot microservices (Eureka Server, Customer, Fraud, SMS services via RabbitMQ, Kafka, and Twilio).

The base configuration is designed to be environment-agnostic and can be customized using overlays.

### `base/networkPolicies/`
Contains environment-specific network policies:
- `dev/` is included by the development overlay.
- `prod/` is included by the production overlay.

These policies are not included by `base/` directly so each overlay owns only the namespace it deploys.

### `overlays/`
Contains environment-specific Kustomize overlays for `dev` and `prod`.

### `platform/`
Contains platform-specific configuration. The current platform is the Helmfile-driven observability stack.

### `argocd/`
Contains Argo CD app-of-apps and ApplicationSet examples. See `argocd/README.md` for k3d, Traefik, Helm, Argo CD, and deployment commands.

## Usage

To deploy the base configuration:
```bash
kubectl apply -k namespaces/
kubectl apply -k base/
```

For environment-specific deployments, create overlays in the `overlays/` directory and apply them:
```bash
kubectl apply -k overlays/<environment>/
```

## Monitoring and Observability

The configuration includes network policies that allow the monitoring namespace to scrape metrics from application pods and receive traces/logs from the applications. Ensure your monitoring stack (Prometheus, Grafana, Loki, Tempo) is deployed in the `monitoring` namespace.
