#!/usr/bin/env bash
# Verify Prometheus is reachable and scraping your targets.
# Requires: curl, jq
set -euo pipefail

PROM_URL="${PROM_URL:-http://localhost:9090}"

need() { command -v "$1" >/dev/null || { echo "Please install '$1'"; exit 1; }; }
need curl; need jq

echo "==> Checking Prometheus at: ${PROM_URL}"

echo "==> /-/ready"
curl -fsS "${PROM_URL}/-/ready" >/dev/null && echo "Prometheus is READY." || { echo "Not ready"; exit 1; }

echo "==> Targets status"
curl -fsS "${PROM_URL}/api/v1/targets" \
| jq -r '
  .data.activeTargets
  | sort_by(.labels.job, .discoveredLabels.__address__)
  | (["JOB","INSTANCE","STATE","LAST SCRAPE","ERROR"] | @tsv),
    (.[] | [ .labels.job, .discoveredLabels.__address__, .health, .lastScrape, (.lastError // "") ] | @tsv)
' | column -t -s $'\t'

echo "==> Basic query test (up)"
curl -fsS --get "${PROM_URL}/api/v1/query" --data-urlencode 'query=up' \
| jq -r '
  .data.result
  | (["INSTANCE","JOB","UP"] | @tsv),
    (.[] | [ .metric.instance, .metric.job, .value[1] ] | @tsv)
' | column -t -s $'\t'

echo "==> Done."
