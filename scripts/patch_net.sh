#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:-kernel_workspace}"

cd "$WORKSPACE_DIR"

if [[ "${BETTER_NET:-false}" != "true" ]]; then
  exit 0
fi

cd common
wget "https://github.com/$GITHUB_REPOSITORY/raw/refs/heads/$GITHUB_REF_NAME/other_patch/config.patch"
patch -p1 -F 3 < config.patch || true
