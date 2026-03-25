#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:-kernel_workspace}"

mkdir -p "$WORKSPACE_DIR"
cd "$WORKSPACE_DIR"

aria2c -s16 -x16 -k1M "${REPO_URL}/archive/refs/heads/${REPO_ARCHIVE}.zip" -o common.zip
unzip -q common.zip
mv "${REPO_EXTRACT_NAME}" common
rm -rf common.zip
