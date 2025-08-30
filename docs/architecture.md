# System Architecture

The DevOps Centralized Monitoring System integrates **Prometheus, Grafana, ELK Stack, and exporters/agents** into a unified platform.

---

## 🔹 High-Level Overview

     ┌──────────────┐
     │ Linux Server │── Node Exporter ─┐
     └──────────────┘                  │
                                       │
     ┌──────────────┐                  │
     │ Windows Host │── Windows Exporter│
     └──────────────┘                  │
                                       │
     ┌──────────────┐                  │
     │  Any Server  │── Metricbeat/Filebeat (logs + extended metrics)
     └──────────────┘                  │
                                       ▼
                      ┌─────────────────────────┐
                      │       Prometheus        │
                      │  - Scrapes metrics      │
                      │  - Applies alert rules  │
                      └─────────┬───────────────┘
                                │
                   ┌────────────┴─────────────┐
                   │                          │
     ┌─────────────▼─────────────┐   ┌────────▼────────┐
     │        Grafana            │   │  Alertmanager   │
     │  - Dashboards             │   │  - Routes alerts│
     │  - Visualization          │   │  - Sends notify │
     └─────────────┬─────────────┘   └────────┬────────┘
                   │                          │
                   │                          │
        ┌──────────▼─────────┐                │
        │        Users       │ <──────────────┘
        │ DevOps / Infosec   │
        └────────────────────┘


     ┌─────────────────────┐
     │ Elasticsearch       │ <── Logstash <── Metricbeat/Filebeat
     │ Stores logs/metrics │
     └─────────┬───────────┘
               │
       ┌───────▼───────┐
       │    Kibana     │
       │  Log analysis │
       └───────────────┘

---

## 🔹 Components

- **Prometheus**
  - Scrapes metrics from Node/Windows Exporter and Metricbeat.
  - Stores time-series data.
  - Evaluates alerting rules.

- **Grafana**
  - Visualizes metrics from Prometheus & Elasticsearch.
  - Provides dashboards for CPU, memory, disk, and network.
  - Supports multi-tenancy and sharing.

- **Alertmanager**
  - Routes alerts from Prometheus to notification channels (Email, Slack, Teams, etc.).
  - Supports silencing, inhibition, and grouping.

- **ELK Stack**
  - **Elasticsearch**: Centralized log & metric store.
  - **Logstash**: Processes log pipelines.
  - **Kibana**: Visualization for logs, troubleshooting, and auditing.

- **Exporters & Beats**
  - **Node Exporter**: Linux server metrics.
  - **Windows Exporter**: Windows host metrics.
  - **Metricbeat**: Extended system metrics.
  - **Filebeat**: Log forwarding.

---

## 🔹 Data Flow

1. **Agents/Exporters** expose metrics on servers.
2. **Prometheus** scrapes these metrics at regular intervals.
3. Metrics are stored in Prometheus TSDB and visualized in Grafana.
4. **Alertmanager** triggers alerts when rules are violated.
5. **Filebeat/Metricbeat** ship logs & events to **Logstash → Elasticsearch**.
6. **Kibana** provides centralized log search & analysis.

---

## 🔹 Scalability

- Horizontal scaling: run multiple Prometheus instances (per-team, per-region).
- Sharding and federation for large infrastructures.
- Elasticsearch can form clusters with multiple nodes for high availability.
