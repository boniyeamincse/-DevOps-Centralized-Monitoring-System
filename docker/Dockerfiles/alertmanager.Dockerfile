# Use the official Alertmanager image as a base
FROM prom/alertmanager:v0.26.0

# Copy the Alertmanager configuration file
COPY ../../prometheus/alertmanager.yml /etc/alertmanager/alertmanager.yml

# Expose the Alertmanager port
EXPOSE 9093

# Set the command to run when the container starts
CMD ["--config.file=/etc/alertmanager/alertmanager.yml", "--storage.path=/alertmanager"]
