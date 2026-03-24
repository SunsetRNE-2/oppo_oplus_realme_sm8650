#!/usr/bin/env bash
set -euo pipefail

resolve_ksu_typename_short() {
  case "${1:-}" in
    sukisu) echo "SukiSU" ;;
    resukisu) echo "ReSukiSU" ;;
    ksunext) echo "KSUNext" ;;
    ksu) echo "KSU" ;;
    none) echo "none" ;;
    *) echo "unknown" ;;
  esac
}

resolve_ksu_typename_full() {
  case "${1:-}" in
    sukisu) echo "SukiSU Ultra" ;;
    resukisu) echo "ReSukiSU" ;;
    ksunext) echo "KernelSU Next" ;;
    ksu) echo "KernelSU (Official)" ;;
    none) echo "无内置KSU" ;;
    *) echo "Unknown" ;;
  esac
}

resolve_full_version() {
  local kernel_version="$1"
  local kernel_name="$2"
  local suffix="${3:-}"
  if [[ -n "$suffix" ]]; then
    echo "${kernel_version}-${suffix}"
  else
    echo "${kernel_version}-${kernel_name}"
  fi
}

pack_anykernel() {
  local workspace="$1"
  local anykernel_repo="$2"
  local image_rel_path="$3"
  local ksu_type="$4"
  local ksuver="${5:-0}"
  local kernel_main="$6"
  local kernel_sub="$7"
  local kernel_name="$8"
  local kernel_suffix="${9:-}"
  local lz4kd_enable="${10}"
  local kpm_enable="${11}"

  cd "$workspace"

  rm -rf AnyKernel3

  if [[ -n "${ANYKERNEL_BRANCH:-}" ]]; then
    git clone "$anykernel_repo" --depth=1 -b "$ANYKERNEL_BRANCH" AnyKernel3 >&2
  else
    git clone "$anykernel_repo" --depth=1 AnyKernel3 >&2
  fi

  rm -rf ./AnyKernel3/.git
  cd AnyKernel3

  cp "../common/${image_rel_path}" ./Image
  if [[ ! -f ./Image ]]; then
    echo "未找到内核镜像文件: ../common/${image_rel_path}" >&2
    return 1
  fi

  if [[ "$lz4kd_enable" == "true" ]]; then
    wget -q "https://raw.githubusercontent.com/$GITHUB_REPOSITORY/refs/heads/$GITHUB_REF_NAME/zram.zip" -O zram.zip >&2
  fi

  if [[ "$kpm_enable" == "kpn" ]]; then
    wget -q "https://github.com/cctv18/KPatch-Next/releases/latest/download/kpn.zip" -O kpn.zip >&2
  fi

  local short_name
  short_name="$(resolve_ksu_typename_short "$ksu_type")"

  local ak3_name
  if [[ -n "$kernel_suffix" ]]; then
    ak3_name="AnyKernel3_${short_name}_${ksuver}_${kernel_main}_${kernel_suffix}.zip"
  else
    ak3_name="AnyKernel3_${short_name}_${ksuver}_${kernel_main}_${kernel_name}.zip"
  fi

  local full_version
  full_version="$(resolve_full_version "${kernel_main}.${kernel_sub}" "$kernel_name" "$kernel_suffix")"

  local time_now
  time_now="$(TZ='Asia/Shanghai' date +'%Y-%m-%d %H:%M:%S')"

  {
    echo "Author: $GITHUB_ACTOR"
    echo "Repo: $GITHUB_REPOSITORY"
    echo "Branch: $GITHUB_REF_NAME"
    echo "Run ID: $GITHUB_RUN_ID"
    echo "Commit: $GITHUB_SHA"
    echo "Time: $time_now"
    echo "Kernel Ver: $full_version"
    echo "KSU Branch: $short_name"
    echo "KSU Ver: ${ksuver}"
    echo "susfs: ${INPUT_SUSFS_ENABLE:-}"
    echo "KPM: ${INPUT_KPM_ENABLE:-}"
    echo "LZ4: ${INPUT_LZ4_ENABLE:-}"
    echo "LZ4KD: ${INPUT_LZ4KD_ENABLE:-}"
    echo "IPset: ${INPUT_BETTER_NET:-}"
    echo "BBR&Brutal: ${INPUT_BBR_ENABLE:-}"
    echo "SSG: ${INPUT_SSG_ENABLE:-}"
    echo "Re-Kernel: ${INPUT_REKERNEL_ENABLE:-}"
    echo "BBG: ${INPUT_BASEBAND_GUARD:-}"
  } > ./ak3.log

  zip -rq "../${ak3_name}" . >&2
  zip -zq "../${ak3_name}" < ./ak3.log >&2

  echo "$ak3_name"
}
