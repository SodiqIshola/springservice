# Environments

This directory contains environment-specific configuration files for the Helmfile deployments of the observability tools.

Each subdirectory represents a different environment (e.g., `prod/` for production), and the YAML files within define global variables that apply to all observability tools in that environment. These variables can override default settings for components like Prometheus, Grafana, Loki, Tempo, OTEL Collector, cAdvisor, and Promtail.

For example, the `prod.yaml` file sets global configurations that are shared across all releases in the production environment.
