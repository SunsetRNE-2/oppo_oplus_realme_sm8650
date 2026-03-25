#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:-kernel_workspace}"

cd "$WORKSPACE_DIR"

git clone https://github.com/cctv18/AnyKernel3 --depth=1
rm -rf ./AnyKernel3/.git
cd AnyKernel3

cp ../common/out/arch/arm64/boot/Image ./Image

if [[ ! -f ./Image ]]; then
  echo "未找到内核镜像文件，构建可能出错"
  exit 1
fi

KSU_TYPENAME="${KSU_TYPE_NAME:-none}"

if [[ "${LZ4KD_ENABLE:-false}" == 'true' ]]; then
  wget "https://raw.githubusercontent.com/$GITHUB_REPOSITORY/refs/heads/$GITHUB_REF_NAME/zram.zip"
fi

if [[ "${KPM_ENABLE:-false}" == 'kpn' ]]; then
  wget https://github.com/cctv18/KPatch-Next/releases/latest/download/kpn.zip
fi

if [[ -n "${KERNEL_SUFFIX:-}" ]]; then
  AK3_NAME="AnyKernel3_${KSU_TYPENAME}_${KSUVER}_${KERNEL_VERSION}_${KERNEL_SUFFIX}.zip"
else
  AK3_NAME="AnyKernel3_${KSU_TYPENAME}_${KSUVER}_${KERNEL_VERSION}_${KERNEL_NAME}.zip"
fi

zip -r "../$AK3_NAME" ./*

if [[ -n "${KERNEL_SUFFIX:-}" ]]; then
  FULL_VERSION="${KERNEL_VERSION}.${SUB_VERSION}-${KERNEL_SUFFIX}"
else
  FULL_VERSION="${KERNEL_VERSION}.${SUB_VERSION}-${KERNEL_NAME}"
fi

TIME_NOW="$(TZ='Asia/Shanghai' date +'%Y-%m-%d %H:%M:%S')"
echo "Author: $GITHUB_ACTOR" > ./ak3.log
echo "Repo: $GITHUB_REPOSITORY" >> ./ak3.log
echo "Branch: $GITHUB_REF_NAME" >> ./ak3.log
echo "Run ID: $GITHUB_RUN_ID" >> ./ak3.log
echo "Commit: $GITHUB_SHA" >> ./ak3.log
echo "Time: $TIME_NOW" >> ./ak3.log
echo "Kernel Ver: $FULL_VERSION" >> ./ak3.log
echo "KSU Branch: ${KSU_TYPENAME}" >> ./ak3.log
echo "KSU Ver: ${KSUVER}" >> ./ak3.log
echo "susfs: ${SUSFS_ENABLE:-}" >> ./ak3.log
echo "KPM: ${KPM_ENABLE:-}" >> ./ak3.log
echo "LZ4: ${LZ4_ENABLE:-}" >> ./ak3.log
echo "LZ4KD: ${LZ4KD_ENABLE:-}" >> ./ak3.log
echo "IPset: ${BETTER_NET:-}" >> ./ak3.log
echo "BBR&Brutal: ${BBR_ENABLE:-}" >> ./ak3.log
echo "SSG: ${SSG_ENABLE:-}" >> ./ak3.log
echo "Re-Kernel: ${REKERNEL_ENABLE:-}" >> ./ak3.log
echo "BBG: ${BASEBAND_GUARD:-}" >> ./ak3.log
zip -z "../$AK3_NAME" < ./ak3.log

echo "AK3_NAME=$AK3_NAME" >> "$GITHUB_ENV"
