# Installation Guide

This guide provides step-by-step instructions for setting up the DevOps Centralized Monitoring System.

---

## 🔹 Prerequisites

Before you begin, ensure you have the following installed on your local machine:

-   [Docker](https://docs.docker.com/get-docker/) (version 20.10 or later)
-   [Docker Compose](https://docs.docker.com/compose/install/) (version 1.29 or later)
-   [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

---

## 🔹 Installation Steps

### 1. Clone the Repository

Clone the project repository from GitHub:

```bash
git clone https://github.com/boniyeamincse/-DevOps-Centralized-Monitoring-System.git
cd DevOps-Centralized-Monitoring-System
```

### 2. Configure Environment Variables

The project uses a `.env` file to manage environment-specific variables. A `.env.example` file is provided as a template.

1.  **Create the `.env` file:**

    ```bash
    cp .env.example .env
    ```

2.  **Edit the `.env` file:**

    Open the `.env` file and customize the variables as needed. At a minimum, you should set the following:

    -   `TIMEZONE`: The timezone for the services (e.g., `Asia/Dhaka`).
    -   `GF_SECURITY_ADMIN_USER`: The Grafana admin username.
    -   `GF_SECURITY_ADMIN_PASSWORD`: The Grafana admin password.

### 3. Start the Monitoring Stack

Once you have configured your environment variables, you can start the entire monitoring stack using Docker Compose:

```bash
docker-compose up -d
```

This command will build the custom Docker images (if they don't exist) and start all the services in the background.

### 4. Verify the Services

You can check the status of the running containers using the following command:

```bash
docker-compose ps
```

You should see all the services running (`prometheus`, `grafana`, `elasticsearch`, etc.).

### 5. Access the Services

The services are now accessible at the following URLs:

-   **Grafana**: `http://localhost:3000`
-   **Prometheus**: `http://localhost:9090`
-   **Alertmanager**: `http://localhost:9093`
-   **Kibana**: `http://localhost:5601`
-   **Elasticsearch**: `http://localhost:9200`

---

## 🔹 Post-Installation

### Configure Prometheus Targets

To start monitoring your servers, you need to add them to the Prometheus configuration.

1.  Open `prometheus/targets/linux_targets.yml` or `prometheus/targets/windows_targets.yml`.
2.  Add the IP addresses and ports of your target servers.

    **Example (`linux_targets.yml`):**

    ```yaml
    - targets:
        - "192.168.1.100:9100"
        - "192.168.1.101:9100"
      labels:
        env: "production"
    ```

3.  Restart Prometheus to apply the changes:

    ```bash
    docker-compose restart prometheus
    ```

### Install Agents

You will need to install the appropriate agents on your target servers. See the [Agents Guide](./agents.md) for detailed instructions.

---

## 🔹 Troubleshooting

If you encounter any issues during installation, please check the following:

-   **Docker and Docker Compose are running.**
-   **The required ports are not already in use on your local machine.**
-   **Check the container logs for any errors:**

    ```bash
    docker-compose logs -f <service_name>
    ```

If you are still having trouble, please [open an issue](https://github.com/boniyeamincse/-DevOps-Centralized-Monitoring-System/issues) on GitHub.
