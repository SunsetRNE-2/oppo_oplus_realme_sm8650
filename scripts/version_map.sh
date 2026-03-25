#!/usr/bin/env bash
set -euo pipefail

KERNEL_VERSION_INPUT="${1:-}"

if [[ -z "$KERNEL_VERSION_INPUT" ]]; then
  echo "Usage: $0 <kernel_version>" >&2
  exit 1
fi

case "$KERNEL_VERSION_INPUT" in
  "6.1.57")
    SUB_VERSION="57"
    ANDROID_VERSION="android14"
    SUSFS_BRANCH_ANDROID="android14"
    KERNEL_NAME="android14-11-o-gca13bffobf09"
    CCACHE_KEY="ccache-neov3-6.1.57"
    REPO_URL="https://github.com/cctv18/android_kernel_common_oneplus_sm8650"
    REPO_ARCHIVE="oneplus/sm8650_u_14.0.0_oneplus12"
    REPO_EXTRACT_NAME="android_kernel_common_oneplus_sm8650-oneplus-sm8650_u_14.0.0_oneplus12"
    PLATFORM_NAME="SM8650"
    DEVICE_DESC="欧加真骁龙8Gen3通用"
    SOURCE_DESC="基于一加12 6.1.57 Android 14 版官方OKI源码"
    ;;
  "6.1.75")
    SUB_VERSION="75"
    ANDROID_VERSION="android15"
    SUSFS_BRANCH_ANDROID="android15"
    KERNEL_NAME="android14-11-o-gca13bffobf09"
    CCACHE_KEY="ccache-neov3-6.1.75"
    REPO_URL="https://github.com/cctv18/android_kernel_common_oneplus_sm8650"
    REPO_ARCHIVE="oneplus/sm8650_v_15.0.0_oneplus12"
    REPO_EXTRACT_NAME="android_kernel_common_oneplus_sm8650-oneplus-sm8650_v_15.0.0_oneplus12"
    PLATFORM_NAME="SM8650"
    DEVICE_DESC="欧加真骁龙8Gen3通用"
    SOURCE_DESC="基于一加12 6.1.75 Android 15 版官方OKI源码"
    ;;
  "6.1.115")
    SUB_VERSION="115"
    ANDROID_VERSION="android15"
    SUSFS_BRANCH_ANDROID="android15"
    KERNEL_NAME="android14-11-o-gca13bffobf09"
    CCACHE_KEY="ccache-neov3-6.1.115"
    REPO_URL="https://github.com/cctv18/android_kernel_oneplus_mt6989"
    REPO_ARCHIVE="oneplus/mt6989_v_15.0.2_ace5_race"
    REPO_EXTRACT_NAME="android_kernel_oneplus_mt6989-oneplus-mt6989_v_15.0.2_ace5_race"
    PLATFORM_NAME="MT6989"
    DEVICE_DESC="欧加真天玑9400e通用"
    SOURCE_DESC="基于一加Ace5竞速版 6.1.115 Android 15 版官方OKI源码"
    ;;
  "6.1.118")
    SUB_VERSION="118"
    ANDROID_VERSION="android16"
    SUSFS_BRANCH_ANDROID="android15"
    KERNEL_NAME="android14-11-o-gca13bffobf09"
    CCACHE_KEY="ccache-neov4-6.1.118"
    REPO_URL="https://github.com/cctv18/android_kernel_common_oneplus_sm8650"
    REPO_ARCHIVE="oneplus/sm8650_b_16.0.0_oneplus12"
    REPO_EXTRACT_NAME="android_kernel_common_oneplus_sm8650-oneplus-sm8650_b_16.0.0_oneplus12"
    PLATFORM_NAME="SM8650"
    DEVICE_DESC="欧加真骁龙8Gen3通用"
    SOURCE_DESC="基于一加12 6.1.118 Android 16 版官方OKI源码"
    ;;
  "6.1.128")
    SUB_VERSION="128"
    ANDROID_VERSION="android15"
    SUSFS_BRANCH_ANDROID="android15"
    KERNEL_NAME="android14-11-o-gca13bffobf09"
    CCACHE_KEY="ccache-neov3-6.1.128"
    REPO_URL="https://github.com/cctv18/android_kernel_oneplus_mt6897"
    REPO_ARCHIVE="oneplus/mt6897_v_15.0.0_oneplus_pad"
    REPO_EXTRACT_NAME="android_kernel_oneplus_mt6897-oneplus-mt6897_v_15.0.0_oneplus_pad"
    PLATFORM_NAME="MT6897"
    DEVICE_DESC="欧加真天玑8350通用"
    SOURCE_DESC="基于一加平板 6.1.128 Android 15 版官方OKI源码"
    ;;
  "6.1.134")
    SUB_VERSION="134"
    ANDROID_VERSION="android16"
    SUSFS_BRANCH_ANDROID="android15"
    KERNEL_NAME="android14-11-o-gca13bffobf09"
    CCACHE_KEY="ccache-neov3-6.1.134"
    REPO_URL="https://github.com/cctv18/android_kernel_oneplus_mt6989"
    REPO_ARCHIVE="oneplus/mt6989_b_16.0.0_ace5_race"
    REPO_EXTRACT_NAME="android_kernel_oneplus_mt6989-oneplus-mt6989_b_16.0.0_ace5_race"
    PLATFORM_NAME="MT6989"
    DEVICE_DESC="欧加真天玑9400e通用"
    SOURCE_DESC="基于一加Ace5竞速版 6.1.134 Android 16 版官方OKI源码"
    ;;
  *)
    echo "Unknown kernel version: $KERNEL_VERSION_INPUT" >&2
    exit 1
    ;;
esac

cat <<EOF
SUB_VERSION=$SUB_VERSION
ANDROID_VERSION=$ANDROID_VERSION
SUSFS_BRANCH_ANDROID=$SUSFS_BRANCH_ANDROID
KERNEL_NAME=$KERNEL_NAME
CCACHE_KEY=$CCACHE_KEY
REPO_URL=$REPO_URL
REPO_ARCHIVE=$REPO_ARCHIVE
REPO_EXTRACT_NAME=$REPO_EXTRACT_NAME
PLATFORM_NAME=$PLATFORM_NAME
DEVICE_DESC=$DEVICE_DESC
SOURCE_DESC=$SOURCE_DESC
EOF
