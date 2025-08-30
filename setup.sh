#!/usr/bin/env bash
# DevOps Centralized Monitoring System - Setup Script
# Run this after cloning the repo: ./setup.sh
# It installs dependencies (Docker/Compose), builds images, and starts the stack.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_COMPOSE="docker compose"

echo "==> DevOps Monitoring Setup"

# ----------- Detect OS -----------
detect_os() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "$ID"
  else
    echo "unknown"
  fi
}

# ----------- Install Docker + Compose if missing -----------
install_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "==> Installing Docker..."
    OS_ID="$(detect_os)"
    if [[ "$OS_ID" =~ (ubuntu|debian) ]]; then
      apt-get update -y
      apt-get install -y docker.io docker-compose-plugin
    elif [[ "$OS_ID" =~ (centos|rhel|rocky|almalinux|fedora) ]]; then
      yum install -y docker docker-compose-plugin
    else
      echo "Unsupported OS, please install Docker manually."
      exit 1
    fi
    systemctl enable --now docker
  fi
}

# ----------- Start stack -----------
start_stack() {
  echo "==> Building and starting stack..."
  cd "$ROOT_DIR/docker"
  $DOCKER_COMPOSE build
  $DOCKER_COMPOSE up -d
}

# ----------- Run tests -----------
run_tests() {
  echo "==> Running connectivity test..."
  bash "$ROOT_DIR/tests/connectivity_test.sh" || true
  echo "==> Running alert rules check..."
  bash "$ROOT_DIR/tests/alert_test.sh" list || true
}

# ----------- Main -----------
main() {
  install_docker
  start_stack
  run_tests

  echo "==> Setup complete!"
  echo "Services:"
  echo "  Prometheus     → http://localhost:9090"
  echo "  Alertmanager   → http://localhost:9093"
  echo "  Grafana        → http://localhost:3000  (admin/admin)"
  echo "  Elasticsearch  → http://localhost:9200"
  echo "  Kibana         → http://localhost:5601"
}

main "$@"
