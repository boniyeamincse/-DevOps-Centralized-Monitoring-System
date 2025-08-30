# Use the official Prometheus image as a base
FROM prom/prometheus:v2.47.0

# Copy the Prometheus configuration file
COPY ../../prometheus/prometheus.yml /etc/prometheus/prometheus.yml

# Copy the alert rules
COPY ../../prometheus/rules /etc/prometheus/rules

# Expose the Prometheus port
EXPOSE 9090

# Set the command to run when the container starts
CMD ["--config.file=/etc/prometheus/prometheus.yml", "--storage.tsdb.path=/prometheus"]
