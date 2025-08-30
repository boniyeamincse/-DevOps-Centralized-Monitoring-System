# Prometheus with repo configs
FROM prom/prometheus:latest
ENV TZ=Asia/Dhaka
# Copy configs into image (immutable builds). You can also bind-mount in compose.
COPY prometheus/prometheus.yml /etc/prometheus/prometheus.yml
COPY prometheus/rules /etc/prometheus/rules
COPY prometheus/targets /etc/prometheus/targets
