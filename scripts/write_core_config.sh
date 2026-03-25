#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:-kernel_workspace}"
DEFCONFIG_PATH="${2:-./common/arch/arm64/configs/gki_defconfig}"

cd "$WORKSPACE_DIR"

append_cfg() {
  echo "$1" >> "$DEFCONFIG_PATH"
}

append_cfg "CONFIG_KSU=y"

if [[ "${KPM_ENABLE:-false}" == "builtin" && ( "${KSU_TYPE:-}" == "sukisu" || "${KSU_TYPE:-}" == "resukisu" ) ]]; then
  append_cfg "CONFIG_KPM=y"
fi

if [[ "${SUSFS_ENABLE:-false}" == "true" ]]; then
  append_cfg "CONFIG_KSU_SUSFS=y"
  append_cfg "CONFIG_KSU_SUSFS_HAS_MAGIC_MOUNT=y"
  append_cfg "CONFIG_KSU_SUSFS_SUS_PATH=y"
  append_cfg "CONFIG_KSU_SUSFS_SUS_MOUNT=y"
  append_cfg "CONFIG_KSU_SUSFS_AUTO_ADD_SUS_KSU_DEFAULT_MOUNT=y"
  append_cfg "CONFIG_KSU_SUSFS_AUTO_ADD_SUS_BIND_MOUNT=y"
  append_cfg "CONFIG_KSU_SUSFS_SUS_KSTAT=y"
  append_cfg "CONFIG_KSU_SUSFS_TRY_UMOUNT=y"
  append_cfg "CONFIG_KSU_SUSFS_AUTO_ADD_TRY_UMOUNT_FOR_BIND_MOUNT=y"
  append_cfg "CONFIG_KSU_SUSFS_SPOOF_UNAME=y"
  append_cfg "CONFIG_KSU_SUSFS_ENABLE_LOG=y"
  append_cfg "CONFIG_KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS=y"
  append_cfg "CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG=y"
  append_cfg "CONFIG_KSU_SUSFS_OPEN_REDIRECT=y"
  append_cfg "CONFIG_KSU_SUSFS_SUS_MAP=y"
else
  append_cfg "CONFIG_KSU_SUSFS=n"
fi

append_cfg "CONFIG_TMPFS_XATTR=y"
append_cfg "CONFIG_TMPFS_POSIX_ACL=y"
append_cfg "CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=y"
append_cfg "CONFIG_HEADERS_INSTALL=n"

if [[ "${LZ4KD_ENABLE:-false}" == "true" ]]; then
  append_cfg "CONFIG_ZSMALLOC=y"
  append_cfg "CONFIG_CRYPTO_LZ4HC=y"
  append_cfg "CONFIG_CRYPTO_LZ4K=y"
  append_cfg "CONFIG_CRYPTO_LZ4KD=y"
  append_cfg "CONFIG_CRYPTO_842=y"
fi

sed -i 's/check_defconfig//' ./common/build.config.gki || true
