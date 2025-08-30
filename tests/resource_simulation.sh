#!/usr/bin/env bash
# DevOps Monitoring – Resource Simulation
# This script simulates high CPU or memory usage to test alerting rules.

set -euo pipefail

# --- Functions ---

function simulate_cpu() {
  local duration_seconds="$1"
  local num_cores
  num_cores=$(nproc)

  echo "Simulating high CPU usage on ${num_cores} cores for ${duration_seconds} seconds..."

  for i in $(seq 1 "${num_cores}"); do
    dd if=/dev/zero bs=1M count=1024 | sha256sum > /dev/null &
  done

  sleep "${duration_seconds}"

  echo "Stopping CPU simulation..."
  killall dd sha256sum
}

function simulate_memory() {
  local memory_mb="$1"
  local duration_seconds="$2"

  echo "Simulating high memory usage (${memory_mb}MB) for ${duration_seconds} seconds..."

  # Create a simple C program to allocate memory
  cat > /tmp/alloc.c <<EOF
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Usage: %s <memory_in_mb>\n", argv[0]);
        return 1;
    }

    long long memory_to_alloc = atoll(argv[1]) * 1024 * 1024;
    char *buffer = malloc(memory_to_alloc);

    if (buffer == NULL) {
        printf("Failed to allocate memory.\n");
        return 1;
    }

    memset(buffer, 1, memory_to_alloc);
    printf("Allocated %lld bytes of memory. Sleeping...\n", memory_to_alloc);
    sleep(1000000);

    return 0;
}
EOF

  gcc /tmp/alloc.c -o /tmp/alloc
  /tmp/alloc "${memory_mb}" &
  alloc_pid=$!

  sleep "${duration_seconds}"

  echo "Stopping memory simulation..."
  kill "${alloc_pid}"
  rm /tmp/alloc /tmp/alloc.c
}

# --- Main ---

function main() {
  if [[ "$#" -lt 2 ]]; then
    echo "Usage: $0 [cpu|memory] [options]"
    echo "  cpu <duration_seconds>"
    echo "  memory <memory_mb> <duration_seconds>"
    exit 1
  fi

  resource="$1"
  shift

  case "${resource}" in
    cpu)
      simulate_cpu "$@"
      ;;
    memory)
      simulate_memory "$@"
      ;;
    *)
      echo "Invalid resource type: ${resource}"
      exit 1
      ;;
  esac
}

main "$@"
