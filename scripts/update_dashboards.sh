#!/usr/bin/env bash
# Push all Grafana JSON dashboards via API
set -euo pipefail

GRAFANA_URL="${GRAFANA_URL:-http://localhost:3000}"
GRAFANA_USER="${GRAFANA_USER:-admin}"
GRAFANA_PASS="${GRAFANA_PASS:-admin}"
DASH_DIR="${DASH_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../grafana/dashboards" && pwd)}"
FOLDER_UID="${FOLDER_UID:-devops-monitoring}"
FOLDER_TITLE="${FOLDER_TITLE:-DevOps Monitoring}"

auth() {
  echo -n "${GRAFANA_USER}:${GRAFANA_PASS}"
}

ensure_folder() {
  # Create folder if not exists
  if ! curl -fsS -u "$(auth)" "${GRAFANA_URL}/api/folders/${FOLDER_UID}" >/dev/null 2>&1; then
    echo "==> Creating folder '${FOLDER_TITLE}' (uid: ${FOLDER_UID})"
    curl -fsS -u "$(auth)" -H "Content-Type: application/json" \
      -X POST "${GRAFANA_URL}/api/folders" \
      -d "{\"uid\":\"${FOLDER_UID}\",\"title\":\"${FOLDER_TITLE}\"}" >/dev/null
  else
    echo "==> Folder exists: ${FOLDER_UID}"
  fi
}

post_dashboard() {
  local file="$1"
  echo "==> Importing: $(basename "$file")"
  local payload
  payload=$(jq -c --arg folderUid "$FOLDER_UID" '. * { "overwrite": true, "folderUid": $folderUid }' "$file")
  curl -fsS -u "$(auth)" -H "Content-Type: application/json" \
    -X POST "${GRAFANA_URL}/api/dashboards/db" \
    -d "{\"dashboard\": ${payload}, \"overwrite\": true, \"folderUid\": \"${FOLDER_UID}\"}" >/dev/null
}

main() {
  command -v jq >/dev/null || { echo "Please install 'jq'."; exit 1; }
  ensure_folder
  shopt -s nullglob
  for f in "${DASH_DIR}"/*.json; do
    post_dashboard "$f"
  done
  echo "==> Done. Dashboards uploaded to folder '${FOLDER_TITLE}'."
}

main "$@"
