#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:-kernel_workspace}"

cd "$WORKSPACE_DIR"

if [[ "${SUSFS_ENABLE:-false}" != "true" ]]; then
  exit 0
fi

if [[ -z "${SUSFS_BRANCH_ANDROID:-}" ]]; then
  echo "SUSFS_BRANCH_ANDROID is not set" >&2
  exit 1
fi

if [[ "${KSU_TYPE:-none}" != "none" ]]; then
  echo "正在添加susfs补丁..."
  echo "使用 susfs 分支映射: oki-${SUSFS_BRANCH_ANDROID}-${KERNEL_VERSION}"
  git clone --depth=1 https://github.com/cctv18/susfs4oki.git susfs4ksu -b "oki-${SUSFS_BRANCH_ANDROID}-${KERNEL_VERSION}"
  wget "https://github.com/$GITHUB_REPOSITORY/raw/refs/heads/$GITHUB_REF_NAME/other_patch/69_hide_stuff.patch" -O ./common/69_hide_stuff.patch
  cp "./susfs4ksu/kernel_patches/50_add_susfs_in_gki-${SUSFS_BRANCH_ANDROID}-${KERNEL_VERSION}.patch" ./common/
  cp ./susfs4ksu/kernel_patches/fs/* ./common/fs/
  cp ./susfs4ksu/kernel_patches/include/linux/* ./common/include/linux/
  cd ./common
  patch -p1 < "50_add_susfs_in_gki-${SUSFS_BRANCH_ANDROID}-${KERNEL_VERSION}.patch" || true
  patch -p1 -N -F 3 < 69_hide_stuff.patch || true
  cd ..
else
  echo "已选择无内置KernelSU模式，跳过susfs配置..."
fi

if [[ "${KSU_TYPE:-none}" == "ksu" ]]; then
  echo "正在为原版 KernelSU 添加susfs补丁..."
  cp ./susfs4ksu/kernel_patches/KernelSU/10_enable_susfs_for_ksu.patch ./KernelSU/
  cd ./KernelSU
  patch -p1 < 10_enable_susfs_for_ksu.patch || true
fi
