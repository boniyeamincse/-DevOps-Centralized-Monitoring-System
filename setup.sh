#!/usr/bin/env bash
# DevOps Monitoring – Automated Setup Script
# This script automates the setup of the monitoring stack.

set -euo pipefail

# --- Functions ---

function require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "Please run as root (sudo)." >&2
    exit 1
  fi
}

function detect_os() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    echo "${ID:-unknown}"
  else
    echo "unknown"
  fi
}

function install_deps_debian() {
  echo "Updating and upgrading the system..."
  apt-get update -y
  apt-get upgrade -y

  echo "Installing prerequisites..."
  apt-get install -y apt-transport-https ca-certificates curl software-properties-common git

  if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io
  fi

  if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
  fi
}

function install_deps_redhat() {
  echo "Updating and upgrading the system..."
  yum update -y

  echo "Installing prerequisites..."
  yum install -y yum-utils git

  if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum install -y docker-ce docker-ce-cli containerd.io
    systemctl start docker
    systemctl enable docker
  fi

  if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
  fi
}

# --- Main ---

function main() {
  require_root

  os_id=$(detect_os)

  if [[ "${os_id}" == "ubuntu" || "${os_id}" == "debian" ]]; then
    install_deps_debian
  elif [[ "${os_id}" == "centos" || "${os_id}" == "rhel" || "${os_id}" == "rocky" || "${os_id}" == "almalinux" ]]; then
    install_deps_redhat
  else
    echo "Unsupported OS: ${os_id}"
    exit 1
  fi

  if [[ ! -f .env ]]; then
    echo "Creating .env file from .env.example..."
    cp .env.example .env
  fi

  echo "Starting the monitoring stack..."
  docker-compose up -d

  echo "--- Setup Complete ---"
  echo "You can access the services at the following URLs:"
  echo "- Grafana: http://localhost:3000 (default user/pass: admin/admin)"
  echo "- Prometheus: http://localhost:9090"
  echo "- Alertmanager: http://localhost:9093"
  echo "- Kibana: http://localhost:5601"
  echo "- Elasticsearch: http://localhost:9200"
  echo "- Zabbix: http://localhost:8080"
}

main "$@"