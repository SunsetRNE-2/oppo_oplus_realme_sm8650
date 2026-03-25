#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:-kernel_workspace}"

cd "$WORKSPACE_DIR"

if [[ "${BASEBAND_GUARD:-false}" != "true" ]]; then
  exit 0
fi

cd common
curl -sSL https://github.com/cctv18/Baseband-guard/raw/master/setup.sh | bash
sed -i '/^config LSM$/,/^help$/{ /^[[:space:]]*default/ { /baseband_guard/! s/selinux/selinux,baseband_guard/ } }' security/Kconfig
