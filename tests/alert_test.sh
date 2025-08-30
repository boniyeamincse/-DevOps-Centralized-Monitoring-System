#!/usr/bin/env bash
# DevOps Monitoring – Alert Test
# This script sends a sample alert to Alertmanager and checks if it is active.

set -euo pipefail

# --- Configuration ---
ALERTMANAGER_URL="${ALERTMANAGER_URL:-http://localhost:9093}"

# --- Functions ---

function send_alert() {
  echo "Sending sample alert to Alertmanager..."

  curl -s -X POST "${ALERTMANAGER_URL}/api/v1/alerts" \
    -H "Content-Type: application/json" \
    -d '[
      {
        "labels": {
          "alertname": "TestAlert",
          "service": "test-service",
          "severity": "critical",
          "instance": "test-instance"
        },
        "annotations": {
          "summary": "This is a test alert.",
          "description": "This alert was fired from the alert_test.sh script."
        },
        "generatorURL": "http://prometheus.example.com/graph?g0.expr=vector(1)"
      }
    ]'

  echo "Alert sent."
}

function check_alert() {
  echo "Checking for active alerts in Alertmanager..."

  response=$(curl -s "${ALERTMANAGER_URL}/api/v2/alerts")
  active_alerts=$(echo "${response}" | jq -r '.[] | select(.labels.alertname == "TestAlert")')

  if [[ -n "${active_alerts}" ]]; then
    echo "Test alert is active in Alertmanager."
    echo "${active_alerts}"
    return 0
  else
    echo "Test alert is not active in Alertmanager."
    return 1
  fi
}

function resolve_alert() {
  echo "Resolving the test alert..."

  curl -s -X POST "${ALERTMANAGER_URL}/api/v1/alerts" \
    -H "Content-Type: application/json" \
    -d '[
      {
        "labels": {
          "alertname": "TestAlert",
          "service": "test-service",
          "severity": "critical",
          "instance": "test-instance"
        },
        "annotations": {
          "summary": "This is a test alert.",
          "description": "This alert was fired from the alert_test.sh script."
        },
        "endsAt": "'"$(date -u --iso-8601=seconds)"'
      }
    ]'

  echo "Alert resolved."
}

# --- Main ---

function main() {
  if [[ "$#" -eq 0 ]]; then
    echo "Usage: $0 [fire|check|resolve]"
    exit 1
  fi

  action="$1"

  case "${action}" in
    fire)
      send_alert
      ;;
    check)
      check_alert
      ;;
    resolve)
      resolve_alert
      ;;
    *)
      echo "Invalid action: ${action}"
      echo "Usage: $0 [fire|check|resolve]"
      exit 1
      ;;
  esac
}

main "$@"
