# Dashboards Guide

This guide provides an overview of the dashboards included in the DevOps Centralized Monitoring System and explains how to customize them.

---

## 🔹 Grafana Dashboards

Grafana is used for visualizing time-series metrics from Prometheus. The project includes several pre-built dashboards for monitoring server resources.

### Included Dashboards

-   **CPU Dashboard**: Visualizes CPU usage, load, and other CPU-related metrics.
-   **Memory Dashboard**: Shows memory usage, swap usage, and other memory-related metrics.
-   **Disk & Network Dashboard**: Displays disk I/O, disk space usage, network traffic, and other disk and network-related metrics.

### Accessing the Dashboards

1.  Open Grafana in your web browser: `http://localhost:3000`
2.  Log in with the default credentials (`admin/admin` unless you changed them in your `.env` file).
3.  Navigate to the "Dashboards" section to see the list of available dashboards.

### Customizing Dashboards

You can customize the existing dashboards or create new ones to suit your needs.

1.  **Open a dashboard.**
2.  **Click the "Add panel" button** to add a new panel.
3.  **Choose a visualization type** (e.g., Graph, Singlestat, Table).
4.  **Write a Prometheus query** in the "Metrics" tab to fetch the data you want to visualize.
5.  **Customize the panel** using the options in the "General", "Axes", "Legend", and "Display" tabs.
6.  **Save the dashboard.**

---

## 🔹 Kibana Dashboards

Kibana is used for visualizing and analyzing log data from Elasticsearch. While this project does not include pre-built Kibana dashboards, you can easily create your own.

### Creating Kibana Dashboards

1.  **Open Kibana** in your web browser: `http://localhost:5601`
2.  **Go to the "Visualize" section** to create new visualizations (e.g., pie charts, bar charts, line charts) based on your log data.
3.  **Go to the "Dashboard" section** to create a new dashboard.
4.  **Add your visualizations** to the dashboard.
5.  **Save the dashboard.**

### Discovering Logs

The "Discover" section in Kibana allows you to search and filter your logs in real-time. This is a powerful tool for troubleshooting and debugging issues.

1.  **Go to the "Discover" section.**
2.  **Select an index pattern** (e.g., `filebeat-*`, `metricbeat-*`).
3.  **Use the search bar** to search for specific keywords or phrases in your logs.
4.  **Use the time picker** to select a time range.
5.  **Add filters** to narrow down your search results.
