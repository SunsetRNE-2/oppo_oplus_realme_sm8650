#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:-kernel_workspace}"

mkdir -p "$WORKSPACE_DIR"
cd "$WORKSPACE_DIR"

mkdir -p clang20
aria2c -s16 -x16 -k1M \
  https://github.com/cctv18/oneplus_sm8650_toolchain/releases/download/LLVM-Clang20-r547379/clang-r547379.zip \
  -o clang.zip
unzip -q clang.zip -d clang20
rm -rf clang.zip

aria2c -s16 -x16 -k1M \
  https://github.com/cctv18/oneplus_sm8650_toolchain/releases/download/LLVM-Clang20-r547379/build-tools.zip \
  -o build-tools.zip
unzip -q build-tools.zip
rm -rf build-tools.zip
