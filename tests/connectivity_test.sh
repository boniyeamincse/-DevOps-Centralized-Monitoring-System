#!/usr/bin/env bash
# DevOps Monitoring – Connectivity Test
# This script checks if the core monitoring services are up and accessible.

set -euo pipefail

# --- Configuration ---
PROMETHEUS_URL="http://localhost:9090"
GRAFANA_URL="http://localhost:3000"
ALERTMANAGER_URL="http://localhost:9093"
ELASTICSEARCH_URL="http://localhost:9200"
KIBANA_URL="http://localhost:5601"

# --- Functions ---

function check_service() {
  local service_name="$1"
  local url="$2"
  local expected_code="${3:-200}"

  echo -n "Checking ${service_name} at ${url}... "

  response=$(curl -s -o /dev/null -w "%{http_code}" "${url}")

  if [[ "${response}" -eq "${expected_code}" ]]; then
    echo "OK (HTTP ${response})"
    return 0
  else
    echo "FAIL (HTTP ${response})"
    return 1
  fi
}

# --- Main ---

function main() {
  local all_ok=true

  echo "--- Starting Connectivity Tests ---"

  check_service "Prometheus" "${PROMETHEUS_URL}/-/ready" || all_ok=false
  check_service "Grafana" "${GRAFANA_URL}/api/health" || all_ok=false
  check_service "Alertmanager" "${ALERTMANAGER_URL}/-/ready" || all_ok=false
  check_service "Elasticsearch" "${ELASTICSEARCH_URL}" || all_ok=false
  check_service "Kibana" "${KIBANA_URL}/api/status" || all_ok=false

  echo "--- Connectivity Tests Finished ---"

  if [[ "${all_ok}" = true ]]; then
    echo "All services are up and running."
    exit 0
  else
    echo "Some services are not accessible. Please check the container logs."
    exit 1
  fi
}

main "$@"
