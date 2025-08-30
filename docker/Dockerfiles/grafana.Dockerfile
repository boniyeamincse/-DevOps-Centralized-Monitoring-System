FROM grafana/grafana:latest
ENV TZ=Asia/Dhaka
# Provisioning (datasources + dashboards)
COPY grafana/provisioning /etc/grafana/provisioning
COPY grafana/dashboards /etc/grafana/provisioning/dashboards
