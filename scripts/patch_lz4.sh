#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:-kernel_workspace}"

cd "$WORKSPACE_DIR"

if [[ "${LZ4_ENABLE:-false}" != "true" ]]; then
  exit 0
fi

git clone --depth=1 "https://github.com/$GITHUB_REPOSITORY.git" -b "$GITHUB_REF_NAME" "$GITHUB_ACTOR"
cp "./$GITHUB_ACTOR/zram_patch/001-lz4.patch" ./common/
cp "./$GITHUB_ACTOR/zram_patch/lz4armv8.S" ./common/lib
cp "./$GITHUB_ACTOR/zram_patch/002-zstd.patch" ./common/
cd ./common
git apply -p1 < 001-lz4.patch || true
patch -p1 < 002-zstd.patch || true
