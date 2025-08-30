#!/usr/bin/env bash
# DevOps Monitoring – Update Dashboards
# This script uploads all JSON dashboards from the grafana/dashboards directory to Grafana.

set -euo pipefail

# --- Configuration ---
# Set the Grafana URL and API Key here or pass them as environment variables.
GRAFANA_URL="${GRAFANA_URL:-http://localhost:3000}"
GRAFANA_API_KEY="${GRAFANA_API_KEY:-}" # Create an API key in the Grafana UI

DASHBOARDS_DIR="../grafana/dashboards"

# --- Functions ---

function check_deps() {
  if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install it to continue." >&2
    exit 1
  fi
  if ! command -v curl &> /dev/null; then
    echo "Error: curl is not installed. Please install it to continue." >&2
    exit 1
  fi
}

function upload_dashboard() {
  local dashboard_file="$1"
  local dashboard_json

  echo "Processing dashboard: ${dashboard_file}"

  # Prepare the JSON payload for the Grafana API
  dashboard_json=$(jq -c '.' "${dashboard_file}")
  payload="{\"dashboard\":${dashboard_json}, \"overwrite\": true}"

  # Upload the dashboard to Grafana
  response=$(curl -s -w "%{http_code}" -X POST -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${GRAFANA_API_KEY}" \
    -d "${payload}" "${GRAFANA_URL}/api/dashboards/db")

  http_code="${response: -3}"

  if [[ "${http_code}" -eq 200 ]]; then
    echo "Dashboard uploaded successfully."
  else
    echo "Error uploading dashboard. HTTP status code: ${http_code}"
    echo "Response: ${response::-3}"
    return 1
  fi
}

# --- Main ---

function main() {
  check_deps

  if [[ -z "${GRAFANA_API_KEY}" ]]; then
    echo "Error: GRAFANA_API_KEY is not set. Please create an API key in Grafana and set the environment variable." >&2
    exit 1
  fi

  if [[ ! -d "${DASHBOARDS_DIR}" ]]; then
    echo "Error: Dashboards directory not found at ${DASHBOARDS_DIR}" >&2
    exit 1
  fi

  for dashboard_file in "${DASHBOARDS_DIR}"/*.json; do
    if [[ -f "${dashboard_file}" ]]; then
      upload_dashboard "${dashboard_file}"
    fi
  done

  echo "All dashboards have been processed."
}

main "$@"
