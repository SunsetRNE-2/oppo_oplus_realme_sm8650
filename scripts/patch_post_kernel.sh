#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:-kernel_workspace}"

cd "$WORKSPACE_DIR"

if [[ "${KPM_ENABLE:-false}" == 'builtin' && ( "${KSU_TYPE:-}" == "sukisu" || "${KSU_TYPE:-}" == "resukisu" ) ]]; then
  cd common/out/arch/arm64/boot
  curl -LO https://github.com/SukiSU-Ultra/SukiSU_KernelPatch_patch/releases/latest/download/patch_linux
  chmod +x patch_linux
  ./patch_linux
  rm -f Image
  mv oImage Image
  cd ../../../..
fi

if [[ "${KPM_ENABLE:-false}" == 'kpn' ]]; then
  cd common/out/arch/arm64/boot
  wget https://github.com/KernelSU-Next/KPatch-Next/releases/latest/download/kptools-linux
  wget https://github.com/KernelSU-Next/KPatch-Next/releases/latest/download/kpimg-linux
  chmod +x ./kptools-linux
  ./kptools-linux -p -i ./Image -k ./kpimg-linux -o ./oImage
  rm -f Image
  mv oImage Image
fi
