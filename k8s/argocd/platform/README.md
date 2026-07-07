# Platform Deployment

## Overview

This directory contains the ArgoCD configuration for deploying the centralized observability platform. The platform includes all monitoring, logging, and tracing tools that are shared across environments.

## Structure

```
platform/
├── app-projects.yaml              # Platform AppProject with permissions
├── namespaces.yaml                # Application to deploy namespaces (wave -1)
├── platform-helmfile.yaml         # Application to deploy observability stack (wave 0)
├── platform-grafana-provisioning.yaml  # Application to deploy Grafana config (wave 1)
└── platform-root.yaml             # Root application that manages all platform apps
```

## Deployment Order

The platform uses sync waves to ensure proper deployment order:

1. **Wave -1**: Namespaces are created first
2. **Wave 0**: Observability tools (Prometheus, Grafana, Loki, Tempo, OTEL Collector, etc.)
3. **Wave 1**: Grafana provisioning and dashboards

## How to Deploy

Deploy the entire platform with a single command:

```bash
kubectl apply -f k8s/argocd/platform/platform-root.yaml
```

This will create the `platform-root` application in ArgoCD, which will then automatically deploy all child applications in the correct order.

## Components Deployed

- **Namespaces**: `monitoring`, `argocd`
- **Prometheus Stack**: Prometheus, Grafana, Alertmanager, Node Exporter
- **Logging**: Loki, Promtail
- **Tracing**: Tempo
- **Telemetry**: OpenTelemetry Collector
- **Grafana Provisioning**: Dashboards, datasources, alerts

## Environment Configuration

The platform uses the `prod` environment by default for centralized deployment, as observability tools are typically shared across development and production environments.

## Notes

- Platform components are deployed to the `monitoring` namespace
- All tools are configured with persistence enabled
- Grafana is accessible at `http://grafana.monitoring.svc.cluster.local:3000`
- Prometheus is accessible at `http://prometheus.monitoring.svc.cluster.local:9090`</content>
<parameter name="filePath">C:\Java-App\springservice\k8s\argocd\platform\README.md
