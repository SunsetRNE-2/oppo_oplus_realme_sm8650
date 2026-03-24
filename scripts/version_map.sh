#!/usr/bin/env bash
set -euo pipefail

load_version_map() {
  local ver="${1:-}"

  case "$ver" in
    6.1.118)
      KERNEL_VERSION="6.1.118"
      KERNEL_SUBVERSION="118"
      KERNEL_PLATFORM="sm8650"
      ANDROID_VERSION="android14"
      KERNEL_NAME="android14-11-o-gca13bffobf09"

      SOURCE_ZIP="https://github.com/cctv18/android_kernel_common_oneplus_sm8650/archive/refs/heads/oneplus/sm8650_b_16.0.0_oneplus12.zip"
      SOURCE_DIR_NAME="android_kernel_common_oneplus_sm8650-oneplus-sm8650_b_16.0.0_oneplus12"
      SOURCE_OUT_DIR="common"

      DEFCONFIG="gki_defconfig"
      BUILD_TARGET="Image"

      IMAGE_PATH="out/arch/arm64/boot/Image"
      DTB_PATH=""
      DTBO_PATH=""

      ANYKERNEL_REPO="https://github.com/cctv18/AnyKernel3"
      ANYKERNEL_BRANCH=""
      ANYKERNEL_VARIANT="sm8650"

      CCACHE_KEY_PREFIX="ccache-neov4-6.1.118"
      RELEASE_TAG_PREFIX="OPPO-OPlus-Realme-build"
      RELEASE_NAME_PREFIX="OPPO-OPlus-Realme-build"

      CLANG_URL="https://github.com/cctv18/oneplus_sm8650_toolchain/releases/download/LLVM-Clang20-r547379/clang-r547379.zip"
      BUILD_TOOLS_URL="https://github.com/cctv18/oneplus_sm8650_toolchain/releases/download/LLVM-Clang20-r547379/build-tools.zip"
      ;;
    *)
      echo "Unsupported kernel version: $ver" >&2
      return 1
      ;;
  esac
}
