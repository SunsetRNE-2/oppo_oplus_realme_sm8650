#!/usr/bin/env bash
set -euo pipefail

INPUT_VERSION="${1:-${KERNEL_VERSION_FULL:-${KERNEL_VERSION_INPUT:-${KERNEL_VERSION:-}}}}"

if [[ -z "$INPUT_VERSION" ]]; then
  echo "[pro_oki_version_catalog] error: missing kernel version input" >&2
  echo "usage: $0 6.1.118" >&2
  exit 1
fi

if [[ ! "$INPUT_VERSION" =~ ^6\.1\.[0-9]+$ ]]; then
  echo "[pro_oki_version_catalog] error: unsupported version format: $INPUT_VERSION" >&2
  echo "expected format: 6.1.xxx" >&2
  exit 1
fi

KERNEL_VERSION_FULL="$INPUT_VERSION"
KERNEL_VERSION="6.1"
SUB_VERSION="${KERNEL_VERSION_FULL##*.}"

ANDROID_VERSION="android14"
SUSFS_ANDROID_VERSION="android14"

KERNEL_NAME=""
CCACHE_KEY=""
REPO_URL=""
REPO_ARCHIVE=""
REPO_EXTRACT_NAME=""

SOURCE_ANDROID_VERSION=""
PLATFORM_FAMILY=""
DEVICE_DESC=""
SOURCE_DESC=""

case "$KERNEL_VERSION_FULL" in
  "6.1.57")
    KERNEL_NAME="android14-11-o-gca13bffobf09"
    CCACHE_KEY="ccache-neov3-6.1.57"
    REPO_URL="https://github.com/cctv18/android_kernel_common_oneplus_sm8650"
    REPO_ARCHIVE="oneplus/sm8650_u_14.0.0_oneplus12"
    REPO_EXTRACT_NAME="android_kernel_common_oneplus_sm8650-oneplus-sm8650_u_14.0.0_oneplus12"
    SOURCE_ANDROID_VERSION="android14"
    PLATFORM_FAMILY="sm8650"
    DEVICE_DESC="SM8650"
    SOURCE_DESC="OnePlus 12 6.1.57 official source"
    ;;
  "6.1.75")
    KERNEL_NAME="android14-11-o-gca13bffobf09"
    CCACHE_KEY="ccache-neov3-6.1.75"
    REPO_URL="https://github.com/cctv18/android_kernel_common_oneplus_sm8650"
    REPO_ARCHIVE="oneplus/sm8650_v_15.0.0_oneplus12"
    REPO_EXTRACT_NAME="android_kernel_common_oneplus_sm8650-oneplus-sm8650_v_15.0.0_oneplus12"
    SOURCE_ANDROID_VERSION="android15"
    PLATFORM_FAMILY="sm8650"
    DEVICE_DESC="SM8650"
    SOURCE_DESC="OnePlus 12 6.1.75 official source"
    ;;
  "6.1.115")
    KERNEL_NAME="android14-11-o-gca13bffobf09"
    CCACHE_KEY="ccache-neov3-6.1.115"
    REPO_URL="https://github.com/cctv18/android_kernel_oneplus_mt6989"
    REPO_ARCHIVE="oneplus/mt6989_v_15.0.2_ace5_race"
    REPO_EXTRACT_NAME="android_kernel_oneplus_mt6989-oneplus-mt6989_v_15.0.2_ace5_race"
    SOURCE_ANDROID_VERSION="android15"
    PLATFORM_FAMILY="mt6989"
    DEVICE_DESC="MT6989"
    SOURCE_DESC="Ace5 Racing 6.1.115 official source"
    ;;
  "6.1.118")
    KERNEL_NAME="android14-11-o-gca13bffobf09"
    CCACHE_KEY="ccache-neov4-6.1.118"
    REPO_URL="https://github.com/cctv18/android_kernel_common_oneplus_sm8650"
    REPO_ARCHIVE="oneplus/sm8650_b_16.0.0_oneplus12"
    REPO_EXTRACT_NAME="android_kernel_common_oneplus_sm8650-oneplus-sm8650_b_16.0.0_oneplus12"
    SOURCE_ANDROID_VERSION="android16"
    PLATFORM_FAMILY="sm8650"
    DEVICE_DESC="SM8650"
    SOURCE_DESC="OnePlus 12 6.1.118 official source"
    ;;
  "6.1.128")
    KERNEL_NAME="android14-11-o-gca13bffobf09"
    CCACHE_KEY="ccache-neov3-6.1.128"
    REPO_URL="https://github.com/cctv18/android_kernel_oneplus_mt6897"
    REPO_ARCHIVE="oneplus/mt6897_v_15.0.0_oneplus_pad"
    REPO_EXTRACT_NAME="android_kernel_oneplus_mt6897-oneplus-mt6897_v_15.0.0_oneplus_pad"
    SOURCE_ANDROID_VERSION="android15"
    PLATFORM_FAMILY="mt6897"
    DEVICE_DESC="MT6897"
    SOURCE_DESC="OnePlus Pad 6.1.128 official source"
    ;;
  "6.1.134")
    KERNEL_NAME="android14-11-o-gca13bffobf09"
    CCACHE_KEY="ccache-neov3-6.1.134"
    REPO_URL="https://github.com/cctv18/android_kernel_oneplus_mt6989"
    REPO_ARCHIVE="oneplus/mt6989_b_16.0.0_ace5_race"
    REPO_EXTRACT_NAME="android_kernel_oneplus_mt6989-oneplus-mt6989_b_16.0.0_ace5_race"
    SOURCE_ANDROID_VERSION="android16"
    PLATFORM_FAMILY="mt6989"
    DEVICE_DESC="MT6989"
    SOURCE_DESC="Ace5 Racing 6.1.134 official source"
    ;;
  *)
    echo "[pro_oki_version_catalog] error: unsupported kernel version: $KERNEL_VERSION_FULL" >&2
    exit 1
    ;;
esac

CCACHE_FILE_NAME="ccache-${KERNEL_VERSION}.${SUB_VERSION}.tar.zst"
FULL_VERSION_DEFAULT="${KERNEL_VERSION}.${SUB_VERSION}-${KERNEL_NAME}"

emit_env() {
  cat <<EOF
KERNEL_VERSION_FULL=$KERNEL_VERSION_FULL
KERNEL_VERSION=$KERNEL_VERSION
SUB_VERSION=$SUB_VERSION

ANDROID_VERSION=$ANDROID_VERSION
SUSFS_ANDROID_VERSION=$SUSFS_ANDROID_VERSION
SOURCE_ANDROID_VERSION=$SOURCE_ANDROID_VERSION

KERNEL_NAME=$KERNEL_NAME
CCACHE_KEY=$CCACHE_KEY
CCACHE_FILE_NAME=$CCACHE_FILE_NAME

REPO_URL=$REPO_URL
REPO_ARCHIVE=$REPO_ARCHIVE
REPO_EXTRACT_NAME=$REPO_EXTRACT_NAME

PLATFORM_FAMILY=$PLATFORM_FAMILY
DEVICE_DESC=$DEVICE_DESC
SOURCE_DESC=$SOURCE_DESC

FULL_VERSION_DEFAULT=$FULL_VERSION_DEFAULT
EOF
}

emit_env

if [[ "${PRO_OKI_WRITE_GITHUB_ENV:-0}" == "1" && -n "${GITHUB_ENV:-}" ]]; then
  emit_env >> "$GITHUB_ENV"
fi
