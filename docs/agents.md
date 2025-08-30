# Agents Guide

This guide provides instructions for installing and configuring the various agents used by the DevOps Centralized Monitoring System.

---

## 🔹 Overview of Agents

Agents are small, lightweight programs that run on your target servers and collect metrics and logs. This project uses the following agents:

-   **Node Exporter**: For collecting metrics from Linux servers.
-   **Windows Exporter**: For collecting metrics from Windows servers.
-   **Filebeat**: For collecting and forwarding logs.
-   **Metricbeat**: For collecting a wide range of system and service metrics.

---

## 🔹 Node Exporter (Linux)

Node Exporter exposes a wide variety of hardware- and kernel-related metrics for Linux systems.

### Installation

1.  **Download and Install**

    You can download the latest release of Node Exporter from the [Prometheus website](https://prometheus.io/download/#node_exporter).

    ```bash
    wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
    tar xvfz node_exporter-1.3.1.linux-amd64.tar.gz
    sudo mv node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/
    ```

2.  **Create a Systemd Service**

    Create a `node_exporter.service` file to run Node Exporter as a service:

    ```ini
    [Unit]
    Description=Node Exporter
    Wants=network-online.target
    After=network-online.target

    [Service]
    User=node_exporter
    Group=node_exporter
    Type=simple
    ExecStart=/usr/local/bin/node_exporter

    [Install]
    WantedBy=multi-user.target
    ```

3.  **Start the Service**

    ```bash
    sudo useradd -rs /bin/false node_exporter
    sudo systemctl daemon-reload
    sudo systemctl enable node_exporter
    sudo systemctl start node_exporter
    ```

### Configuration

Node Exporter does not require any specific configuration. It will automatically expose metrics on port `9100`.

---

## 🔹 Windows Exporter (Windows)

Windows Exporter is the recommended way to collect metrics from Windows servers.

### Installation

1.  **Download and Install**

    Download the latest MSI installer from the [Windows Exporter GitHub releases page](https://github.com/prometheus-community/windows_exporter/releases).

2.  **Run the Installer**

    Run the MSI installer and follow the on-screen instructions. The installer will set up Windows Exporter as a Windows service.

### Configuration

Windows Exporter will expose metrics on port `9182` by default.

---

## 🔹 Filebeat

Filebeat is a lightweight shipper for forwarding and centralizing log data.

### Installation

Refer to the [official Filebeat documentation](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-installation-configuration.html) for detailed installation instructions.

### Configuration

You will need to configure Filebeat to send logs to either Logstash or Elasticsearch. The configuration file is typically located at `/etc/filebeat/filebeat.yml`.

**Example (sending to Logstash):**

```yaml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/*.log

output.logstash:
  hosts: ["your-logstash-server:5044"]
```

---

## 🔹 Metricbeat

Metricbeat is a lightweight shipper that you can install on your servers to periodically collect metrics from the operating system and from services that run on the server.

### Installation

Refer to the [official Metricbeat documentation](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-installation-configuration.html) for detailed installation instructions.

### Configuration

Configure Metricbeat to send metrics to either Elasticsearch or Logstash. The configuration file is typically located at `/etc/metricbeat/metricbeat.yml`.

**Example (sending to Elasticsearch):**

```yaml
metricbeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false

output.elasticsearch:
  hosts: ["your-elasticsearch-server:9200"]
```
