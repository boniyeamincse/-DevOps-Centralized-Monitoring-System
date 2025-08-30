#!/usr/bin/env bash
# Test alerting pipeline.
# Modes:
#   list               -> show current alerting rules and firing alerts
#   fire-synthetic     -> post a synthetic alert directly to Alertmanager
#   silence-synthetic  -> create a silence for the synthetic alert
#   clear-synthetic    -> expire the synthetic alert (by sending endsAt)
#
# Env:
#   PROM_URL (default http://localhost:9090)
#   AM_URL   (default http://localhost:9093)
#
# Requires: curl, jq
set -euo pipefail
need() { command -v "$1" >/dev/null || { echo "Please install '$1'"; exit 1; }; }
need curl; need jq

PROM_URL="${PROM_URL:-http://localhost:9090}"
AM_URL="${AM_URL:-http://localhost:9093}"
CMD="${1:-list}"

list_rules() {
  echo "==> Listing alerting rules from Prometheus"
  curl -fsS "${PROM_URL}/api/v1/rules" \
  | jq -r '
    .data.groups[]
    | .name as $g
    | .rules[]
    | select(.type=="alerting")
    | [ $g, .name, .state, (.labels.severity // ""), (.annotations.summary // "") ] | @tsv
  ' | (echo -e "GROUP\tALERT\tSTATE\tSEVERITY\tSUMMARY"; cat) | column -t -s $'\t'
}

list_alerts() {
  echo "==> Firing alerts from Prometheus"
  curl -fsS "${PROM_URL}/api/v1/alerts" \
  | jq -r '
    .data.alerts
    | (["ALERT","STATE","SEVERITY","INSTANCE","STARTS AT"] | @tsv),
      (.[] | [ .labels.alertname, .state, (.labels.severity // ""), (.labels.instance // ""), .activeAt ] | @tsv)
  ' | column -t -s $'\t' || true

  echo "==> Alertmanager status (receivers/routes)"
  curl -fsS "${AM_URL}/api/v2/status" | jq '.'
}

fire_synth() {
  echo "==> Sending synthetic alert to Alertmanager (${AM_URL})"
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  ends="$(date -u -d '+15 minutes' +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -v+15M +"%Y-%m-%dT%H:%M:%SZ")"
  payload=$(jq -n --arg start "$now" --arg end "$ends" '
    [{
      "labels": {
        "alertname": "SyntheticAlert_DevOpsMonitoring",
        "severity": "warning",
        "team": "devops",
        "instance": "synthetic/local"
      },
      "annotations": {
        "summary": "Synthetic alert test from alert_test.sh",
        "description": "This is a manual test alert posted to Alertmanager to validate routing and notifications."
      },
      "startsAt": $start,
      "endsAt": $end,
      "generatorURL": "http://prometheus/graph?g0.expr=vector(1)"
    }]
  ')
  curl -fsS -H 'Content-Type: application/json' -d "$payload" "${AM_URL}/api/v1/alerts"
  echo "==> Posted. Check Alertmanager UI and receivers."
}

silence_synth() {
  echo "==> Creating a 15m silence for SyntheticAlert_DevOpsMonitoring"
  ends="$(date -u -d '+15 minutes' +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -v+15M +"%Y-%m-%dT%H:%M:%SZ")"
  payload=$(jq -n --arg ends "$ends" '
    {
      "matchers": [
        {"name":"alertname","value":"SyntheticAlert_DevOpsMonitoring","isRegex":false}
      ],
      "createdBy":"alert_test.sh",
      "comment":"Silence for synthetic alert test",
      "startsAt": (now|todate),
      "endsAt": $ends
    }
  ')
  curl -fsS -H 'Content-Type: application/json' -d "$payload" "${AM_URL}/api/v2/silences" | jq '.id? // .'
}

clear_synth() {
  echo "==> Expiring synthetic alert by posting an ended alert"
  past="$(date -u -d '-1 minute' +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -v-1M +"%Y-%m-%dT%H:%M:%SZ")"
  payload=$(jq -n --arg end "$past" '
    [{
      "labels": { "alertname": "SyntheticAlert_DevOpsMonitoring", "instance":"synthetic/local" },
      "annotations": {"summary":"Expire synthetic alert"},
      "startsAt": (now|todate),
      "endsAt": $end
    }]
  ')
  curl -fsS -H 'Content-Type: application/json' -d "$payload" "${AM_URL}/api/v1/alerts" >/dev/null
  echo "==> Sent ended alert."
}

case "$CMD" in
  list)              list_rules; list_alerts ;;
  fire-synthetic)    fire_synth ;;
  silence-synthetic) silence_synth ;;
  clear-synthetic)   clear_synth ;;
  *)
    echo "Usage: $0 [list|fire-synthetic|silence-synthetic|clear-synthetic]"; exit 1 ;;
esac
