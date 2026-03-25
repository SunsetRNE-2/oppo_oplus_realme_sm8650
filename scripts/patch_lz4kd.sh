#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:-kernel_workspace}"

cd "$WORKSPACE_DIR"

if [[ "${LZ4KD_ENABLE:-false}" != "true" ]]; then
  exit 0
fi

if [ ! -d "SukiSU_patch" ]; then
  git clone --depth=1 https://github.com/ShirkNeko/SukiSU_patch.git
fi

cd common
cp -r ../SukiSU_patch/other/zram/lz4k/include/linux/* ./include/linux/
cp -r ../SukiSU_patch/other/zram/lz4k/lib/* ./lib
cp -r ../SukiSU_patch/other/zram/lz4k/crypto/* ./crypto
cp "../SukiSU_patch/other/zram/zram_patch/${KERNEL_VERSION}/lz4kd.patch" ./
patch -p1 -F 3 < lz4kd.patch || true
