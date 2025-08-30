<p align="center">
  <a href="https://github.com/boniyeamincse/-DevOps-Centralized-Monitoring-System">
    <img src="https://user-images.githubusercontent.com/80245310/214715097-3239b37c-6a84-4352-9b33-1c33013319a5.png" alt="Logo" width="80" height="80">
  </a>
</p>

<h1 align="center">
  DevOps Centralized Monitoring System
</h1>

<p align="center">
    A production-ready, open-source monitoring stack for Linux & Windows servers.
    <br />
    <a href="/docs/architecture.md"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/boniyeamincse/-DevOps-Centralized-Monitoring-System/issues">Report Bug</a>
    ·
    <a href="https://github.com/boniyeamincse/-DevOps-Centralized-Monitoring-System/issues">Request Feature</a>
</p>

<p align="center">
  <a href="https://github.com/boniyeamincse/-DevOps-Centralized-Monitoring-System/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/boniyeamincse/-DevOps-Centralized-Monitoring-System?style=for-the-badge" alt="License">
  </a>
  <a href="https://github.com/boniyeamincse/-DevOps-Centralized-Monitoring-System/stargazers">
    <img src="https://img.shields.io/github/stars/boniyeamincse/-DevOps-Centralized-Monitoring-System?style=for-the-badge" alt="Stargazers">
  </a>
  <a href="https://github.com/boniyeamincse/-DevOps-Centralized-Monitoring-System/network/members">
    <img src="https://img.shields.io/github/forks/boniyeamincse/-DevOps-Centralized-Monitoring-System?style=for-the-badge" alt="Forks">
  </a>
  <a href="https://github.com/boniyeamincse/-DevOps-Centralized-Monitoring-System/issues">
    <img src="https://img.shields.io/github/issues/boniyeamincse/-DevOps-Centralized-Monitoring-System?style=for-the-badge" alt="Issues">
  </a>
</p>

---

## 🚀 Overview

This project provides a robust, all-in-one monitoring solution designed for DevOps and Infrastructure teams. It leverages a powerful stack of open-source tools to provide real-time metrics, logs, and alerts for both **Linux and Windows** environments.

The entire stack is containerized using **Docker Compose**, making it easy to deploy, manage, and scale.

### ✨ Features

-   **Unified Monitoring**: Centralized dashboards for infrastructure and application monitoring.
-   **Metrics & Logging**: Collects both time-series metrics (Prometheus) and logs (ELK Stack).
-   **Cross-Platform**: Supports Linux (via Node Exporter) and Windows (via Windows Exporter).
-   **Alerting**: Pre-configured alerting rules for common issues (CPU, Memory, Disk).
-   **Containerized**: Fully containerized with Docker Compose for easy deployment.
-   **Scalable**: Designed to be scalable from a single server to hundreds.
-   **Customizable**: Easily extend with new exporters, dashboards, and alert rules.

---

## 🛠️ Tech Stack

| Technology      | Description                               |
| --------------- | ----------------------------------------- |
| **Prometheus**  | Time-series database for metrics          |
| **Grafana**     | Visualization and dashboarding            |
| **Alertmanager**| Alerting and notification routing         |
| **ELK Stack**   | Elasticsearch, Logstash, and Kibana for logging |
| **Docker**      | Containerization                          |
| **Exporters**   | Node Exporter (Linux) & Windows Exporter  |
| **Beats**       | Filebeat & Metricbeat for log/metric shipping |

---

## 🏛️ Architecture

The architecture is designed to be modular and scalable.

```
      +-----------------+      +------------------+      +-----------------+
      |  Linux Servers  |      | Windows Servers  |      |   Applications  |
      +-----------------+      +------------------+      +-----------------+
              |                        |                         |
      +-------v--------+      +--------v---------+      +--------v--------+
      |  Node Exporter  |      | Windows Exporter |      |   Custom Exporters |
      +-----------------+      +------------------+      +-----------------+
              |                        |                         |
              +------------------------+-------------------------+
                                       |
                               +-------v--------+
                               |   Prometheus   |
                               +-------+--------+
                                       |
          +----------------------------+----------------------------+
          |                                                         |
+---------v----------+                                    +---------v----------+
|    Alertmanager    |                                    |      Grafana       |
+---------+----------+                                    +--------------------+
          |
+---------v----------+
|   Notifications    |
| (Slack, Email, etc)|
+--------------------+
```

---

## 🏁 Getting Started

### Prerequisites

-   [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/)
-   `git`
-   `make` (optional, for convenience)

### Installation

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/boniyeamincse/-DevOps-Centralized-Monitoring-System.git
    cd DevOps-Centralized-Monitoring-System
    ```

2.  **Configure Environment Variables:**

    Create a `.env` file from the example file and customize it as needed.

    ```bash
    cp .env.example .env
    ```

3.  **Start the Stack:**

    ```bash
    docker-compose up -d
    ```

4.  **Access the Services:**

    -   **Grafana**: `http://localhost:3000` (default user/pass: `admin/admin`)
    -   **Prometheus**: `http://localhost:9090`
    -   **Alertmanager**: `http://localhost:9093`
    -   **Kibana**: `http://localhost:5601`
    -   **Elasticsearch**: `http://localhost:9200`

---

## ⚙️ Configuration

All configuration files are located in their respective directories (`prometheus/`, `grafana/`, `elk/`, etc.).

-   **Prometheus Targets**: Add your server IPs to `prometheus/targets/linux_targets.yml` or `prometheus/targets/windows_targets.yml`.
-   **Alerting Rules**: Customize alerting rules in `prometheus/rules/`.
-   **Grafana Dashboards**: Dashboards are automatically provisioned from the `grafana/dashboards/` directory.
-   **ELK Pipeline**: Configure the Logstash pipeline in `elk/logstash/pipelines.conf`.

---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

---

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 📧 Contact

Boni Yeamin - [boniyeamin.cse@gmail.com](mailto:boniyeamin.cse@gmail.com)

Project Link: [https://github.com/boniyeamincse/-DevOps-Centralized-Monitoring-System](https://github.com/boniyeamincse/-DevOps-Centralized-Monitoring-System)