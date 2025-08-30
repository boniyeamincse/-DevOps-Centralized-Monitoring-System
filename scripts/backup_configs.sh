#!/usr/bin/env bash
# Backup Prometheus / Grafana provisioning / ELK / Zabbix configs into a timestamped tar.gz
set -euo pipefail

TS="$(date +%Y%m%d-%H%M%S)"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="${ROOT_DIR}/logs/setup_logs"
ARCHIVE="${BACKUP_DIR}/devops-monitoring-backup-${TS}.tar.gz"

mkdir -p "${BACKUP_DIR}"

# Paths to back up (adjust if you move things)
INCLUDE_PATHS=(
  "${ROOT_DIR}/prometheus/prometheus.yml"
  "${ROOT_DIR}/prometheus/rules"
  "${ROOT_DIR}/prometheus/targets"
  "${ROOT_DIR}/grafana/provisioning"
  "${ROOT_DIR}/grafana/dashboards"
  "${ROOT_DIR}/elk/elasticsearch/elasticsearch.yml"
  "${ROOT_DIR}/elk/logstash/pipelines.conf"
  "${ROOT_DIR}/elk/kibana/kibana.yml"
  "${ROOT_DIR}/elk/beats/metricbeat.yml"
  "${ROOT_DIR}/elk/beats/filebeat.yml"
  "${ROOT_DIR}/zabbix/server_conf"
  "${ROOT_DIR}/zabbix/agent_conf"
  "${ROOT_DIR}/docker/docker-compose.yml"
  "${ROOT_DIR}/docker/Dockerfiles"
  "${ROOT_DIR}/docs"
)

echo "==> Creating archive: ${ARCHIVE}"
tar -czf "${ARCHIVE}" --absolute-names --transform "s|${ROOT_DIR#/}|devops-monitoring|g" "${INCLUDE_PATHS[@]}" 2>/dev/null || {
  echo "Some files/dirs may be missing; creating archive with existing items..."
  # Rebuild list with existing items only
  EXISTING=()
  for p in "${INCLUDE_PATHS[@]}"; do
    [[ -e "$p" ]] && EXISTING+=("$p")
  done
  tar -czf "${ARCHIVE}" --absolute-names --transform "s|${ROOT_DIR#/}|devops-monitoring|g" "${EXISTING[@]}"
}

echo "==> Backup saved: ${ARCHIVE}"
echo "Tip: Store this in off-site storage (S3/MinIO) on a schedule (e.g., cron)."
