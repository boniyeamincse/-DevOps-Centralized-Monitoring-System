# Alerting Setup Guide

This document provides a guide to setting up and configuring alerting in the DevOps Centralized Monitoring System.

---

## 🔹 Alerting Architecture

The alerting architecture consists of two main components:

1.  **Prometheus**: Evaluates alerting rules defined in the `prometheus/rules/` directory.
2.  **Alertmanager**: Receives alerts from Prometheus and routes them to the configured notification channels.

## 🔹 Alerting Rules

Alerting rules are defined in YAML files in the `prometheus/rules/` directory. You can add as many rule files as you need.

**Example Rule (`cpu_memory_alerts.yml`):**

```yaml
groups:
  - name: server_alerts
    rules:
      - alert: HighCpuUsage
        expr: 100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage on {{ $labels.instance }}"
          description: "CPU usage is above 80% on instance {{ $labels.instance }}."

      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 85
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High memory usage on {{ $labels.instance }}"
          description: "Memory usage is above 85% on instance {{ $labels.instance }}."
```

### Adding New Rules

1.  Create a new YAML file in the `prometheus/rules/` directory.
2.  Define your alert rules using the Prometheus expression language.
3.  Restart the Prometheus container to apply the changes:

    ```bash
    docker-compose restart prometheus
    ```

---

## 🔹 Alertmanager Configuration

Alertmanager is configured via the `alertmanager.yml` file, which should be placed in the `prometheus/` directory. This file defines how alerts are routed, grouped, and sent to notification channels.

**Note:** The `alertmanager.yml` file is not yet created. You will need to create it to configure Alertmanager.

### Notification Channels

Alertmanager supports various notification channels, including:

-   Email
-   Slack
-   PagerDuty
-   Webhook

**Example `alertmanager.yml`:**

```yaml
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname', 'cluster', 'service']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 3h
  receiver: 'default-receiver'

receivers:
  - name: 'default-receiver'
    email_configs:
      - to: 'your-email@example.com'
        from: 'alertmanager@example.com'
        smarthost: 'smtp.example.com:587'
        auth_username: 'your-username'
        auth_password: 'your-password'
```

### Creating `alertmanager.yml`

1.  Create a file named `alertmanager.yml` in the `prometheus/` directory.
2.  Add your Alertmanager configuration to the file.
3.  Update the `docker-compose.yml` file to mount the `alertmanager.yml` file into the `alertmanager` container.

---

## 🔹 Testing Alerts

You can test your alerting setup by using the `resource_simulation.sh` script to generate high CPU or memory usage on a target server.

```bash
./tests/resource_simulation.sh cpu --duration 60
```

This will trigger the `HighCpuUsage` alert if the CPU usage exceeds the threshold defined in the alert rule.