#!/usr/bin/env bash
# Safely simulate resource pressure to test alerts/dashboards.
# Requires: bash; optional: stress-ng (preferred). Falls back to busy CPU/mem loops.
#
# Usage:
#   sudo ./resource_simulation.sh cpu --workers 4 --duration 120
#   sudo ./resource_simulation.sh mem --size 2G --duration 120
#   sudo ./resource_simulation.sh io  --workers 2 --duration 60
#   sudo ./resource_simulation.sh net --iface eth0 --rate 100M --duration 60   (requires iperf3/nping if available)
#
set -euo pipefail

ACTION="${1:-cpu}"
shift || true

DURATION=120
WORKERS="$(nproc || echo 2)"
SIZE="1G"
IFACE=""
RATE="50M"

# Parse simple flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --duration) DURATION="${2:-120}"; shift 2 ;;
    --workers)  WORKERS="${2:-2}";   shift 2 ;;
    --size)     SIZE="${2:-1G}";     shift 2 ;;
    --iface)    IFACE="${2:-}";      shift 2 ;;
    --rate)     RATE="${2:-50M}";    shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

have() { command -v "$1" >/dev/null 2>&1; }

finish() {
  echo "==> Cleaning up..."
  pkill -f 'yes > /dev/null' 2>/dev/null || true
  pkill -f 'dd if=/dev/zero'  2>/dev/null || true
  pkill -f 'stress-ng'        2>/dev/null || true
}
trap finish EXIT

echo "==> Simulation: ${ACTION} for ${DURATION}s"

if [[ "$ACTION" == "cpu" ]]; then
  if have stress-ng; then
    echo "Using stress-ng for CPU load with ${WORKERS} workers"
    stress-ng --cpu "${WORKERS}" --timeout "${DURATION}" --metrics-brief
  else
    echo "Fallback: spawning ${WORKERS} busy loops"
    for _ in $(seq 1 "$WORKERS"); do
      bash -c 'yes > /dev/null' &
    done
    sleep "${DURATION}"
  fi

elif [[ "$ACTION" == "mem" ]]; then
  if have stress-ng; then
    echo "Using stress-ng to allocate ${SIZE}"
    stress-ng --vm 1 --vm-bytes "${SIZE}" --timeout "${DURATION}" --metrics-brief
  else
    echo "Fallback: allocating memory via dd for ${DURATION}s"
    tmpfile="$(mktemp)"
    dd if=/dev/zero of="$tmpfile" bs=1M count=$(( ${SIZE%G} * 1024 )) status=none || true
    sleep "${DURATION}"
    rm -f "$tmpfile"
  fi

elif [[ "$ACTION" == "io" ]]; then
  if have stress-ng; then
    echo "Using stress-ng for IO with ${WORKERS} workers"
    stress-ng --hdd "${WORKERS}" --timeout "${DURATION}" --metrics-brief
  else
    echo "Fallback: writing zeros to temp files"
    for i in $(seq 1 "$WORKERS"); do
      tmpfile="$(mktemp)"
      (dd if=/dev/zero of="$tmpfile" bs=4M count=512 status=none; sleep "${DURATION}"; rm -f "$tmpfile") &
    done
    sleep "${DURATION}"
  fi

elif [[ "$ACTION" == "net" ]]; then
  echo "Network simulation requires extra tools (iperf3 or nping)."
  if have iperf3; then
    echo "Run a server elsewhere: 'iperf3 -s'. Here we run client load."
    iperf3 -c 127.0.0.1 -t "${DURATION}" -b "${RATE}" || true
  elif have nping; then
    nping --udp -c 0 --rate "${RATE}" --data-length 1200 127.0.0.1 --count "$(( DURATION * 10 ))" || true
  else
    echo "No iperf3/nping found. Skipping network simulation."
  fi

else
  echo "Usage: $0 {cpu|mem|io|net} [--duration SEC] [--workers N] [--size 1G] [--iface eth0] [--rate 50M]"
  exit 1
fi

echo "==> Simulation complete."
