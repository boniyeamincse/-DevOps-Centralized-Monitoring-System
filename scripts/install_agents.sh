#!/usr/bin/env bash
# DevOps Monitoring – Install Agents
# - Linux: installs/updates Node Exporter (system metrics)
# - Optional: installs Metricbeat & Filebeat (comment/uncomment)
# - Windows: prints quick install steps for Windows Exporter
set -euo pipefail

NODE_EXPORTER_VERSION="${NODE_EXPORTER_VERSION:-1.8.1}"
NODE_EXPORTER_USER="nodeexp"
NODE_EXPORTER_PORT="${NODE_EXPORTER_PORT:-9100}"

detect_os() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    echo "${ID:-unknown}"
  else
    echo "unknown"
  fi
}

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "Please run as root (sudo)." >&2
    exit 1
  fi
}

install_node_exporter_linux() {
  echo "==> Installing Node Exporter v${NODE_EXPORTER_VERSION} ..."
  id -u "${NODE_EXPORTER_USER}" &>/dev/null || useradd --system --no-create-home --shell /usr/sbin/nologin "${NODE_EXPORTER_USER}"

  cd /tmp
  ARCH="$(uname -m)"
  case "$ARCH" in
    x86_64|amd64)  TARCH="amd64" ;;
    aarch64|arm64) TARCH="arm64" ;;
    *) echo "Unsupported arch: $ARCH" >&2; exit 1 ;;
  esac

  URL="https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-${TARCH}.tar.gz"
  curl -fsSL "$URL" -o node_exporter.tgz
  tar xzf node_exporter.tgz
  install -m 0755 "node_exporter-${NODE_EXPORTER_VERSION}.linux-${TARCH}/node_exporter" /usr/local/bin/node_exporter
  rm -rf "node_exporter-${NODE_EXPORTER_VERSION}.linux-${TARCH}" node_exporter.tgz

  # Systemd unit
  cat >/etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=${NODE_EXPORTER_USER}
Group=${NODE_EXPORTER_USER}
Type=simple
ExecStart=/usr/local/bin/node_exporter \\
  --web.listen-address=":${NODE_EXPORTER_PORT}" \\
  --collector.filesystem.mount-points-exclude="^/(sys|proc|dev|run|var/lib/docker/.+|var/lib/containers/.+)$"

Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable --now node_exporter
  echo "==> Node Exporter running on :${NODE_EXPORTER_PORT}"
}

install_metricbeat_linux() {
  echo "==> Installing Metricbeat (Elastic) ..."
  OS_ID="$(detect_os)"
  if [[ "$OS_ID" == "ubuntu" || "$OS_ID" == "debian" ]]; then
    curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor -o /usr/share/keyrings/elastic.gpg
    echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" >/etc/apt/sources.list.d/elastic-8.x.list
    apt-get update -y
    apt-get install -y metricbeat
  elif [[ "$OS_ID" == "centos" || "$OS_ID" == "rhel" || "$OS_ID" == "rocky" || "$OS_ID" == "almalinux" ]]; then
    rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
    cat >/etc/yum.repos.d/elastic-8.x.repo <<'EOF'
[elastic-8.x]
name=Elastic 8.x
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
    yum install -y metricbeat
  else
    echo "Unsupported Linux distro for Metricbeat automated install."
    return 0
  fi
  systemctl enable metricbeat
  systemctl restart metricbeat
  echo "==> Metricbeat installed and started."
}

install_filebeat_linux() {
  echo "==> Installing Filebeat (Elastic) ..."
  OS_ID="$(detect_os)"
  if [[ "$OS_ID" == "ubuntu" || "$OS_ID" == "debian" ]]; then
    apt-get update -y && apt-get install -y filebeat
  elif [[ "$OS_ID" == "centos" || "$OS_ID" == "rhel" || "$OS_ID" == "rocky" || "$OS_ID" == "almalinux" ]]; then
    yum install -y filebeat
  else
    echo "Unsupported Linux distro for Filebeat automated install."
    return 0
  fi
  systemctl enable filebeat
  systemctl restart filebeat
  echo "==> Filebeat installed and started."
}

print_windows_exporter_steps() {
  cat <<'EOF'
==> Windows Exporter (manual quick steps)
1) Download MSI: https://github.com/prometheus-community/windows_exporter/releases
2) Install with desired collectors (default is fine).
3) Verify service 'windows_exporter' is running and listening on TCP 9182.
4) Open firewall (Admin PowerShell):
   New-NetFirewallRule -DisplayName "Windows Exporter 9182" -Direction Inbound -Protocol TCP -LocalPort 9182 -Action Allow
5) Add the host:9182 to prometheus/targets/windows_targets.yml
EOF
}

usage() {
  cat <<EOF
Usage: sudo $0 [node|metricbeat|filebeat|all]
Default: all

Env vars:
  NODE_EXPORTER_VERSION (default: ${NODE_EXPORTER_VERSION})
  NODE_EXPORTER_PORT    (default: ${NODE_EXPORTER_PORT})
EOF
}

main() {
  require_root
  ACTION="${1:-all}"
  case "$ACTION" in
    node)       install_node_exporter_linux ;;
    metricbeat) install_metricbeat_linux ;;
    filebeat)   install_filebeat_linux ;;
    all)
      install_node_exporter_linux
      # Uncomment if you want Elastic Beats installed by default:
      # install_metricbeat_linux
      # install_filebeat_linux
      ;;
    *)
      usage; exit 1 ;;
  esac
  print_windows_exporter_steps
}

main "$@"
