#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:-kernel_workspace}"

cd "$WORKSPACE_DIR"

if [[ -n "${KERNEL_SUFFIX:-}" ]]; then
  for f in ./common/scripts/setlocalversion; do
    sed -i "\$s|echo \"\\\$res\"|echo \"-${KERNEL_SUFFIX}\"|" "$f"
  done
else
  for f in ./common/scripts/setlocalversion; do
    sed -i "\$s|echo \"\\\$res\"|echo \"-${KERNEL_NAME}\"|" "$f"
  done
fi
