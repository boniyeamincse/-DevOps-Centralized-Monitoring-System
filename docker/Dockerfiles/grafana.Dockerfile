# Use the official Grafana image as a base
FROM grafana/grafana:10.1.5

# Copy the provisioning files
COPY ../../grafana/provisioning /etc/grafana/provisioning

# Copy the dashboard files
COPY ../../grafana/dashboards /var/lib/grafana/dashboards

# Expose the Grafana port
EXPOSE 3000
