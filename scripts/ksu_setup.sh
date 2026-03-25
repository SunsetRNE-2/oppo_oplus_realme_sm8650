#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:-kernel_workspace}"
KSU_TYPE="${2:-resukisu}"
REPO_OWNER_TAG="${3:-SunsetRNE}"

cd "$WORKSPACE_DIR"

if [[ "$KSU_TYPE" == "sukisu" ]]; then
  echo "正在配置SukiSU Ultra..."
  curl -LSs "https://raw.githubusercontent.com/ShirkNeko/SukiSU-Ultra/refs/heads/main/kernel/setup.sh" | bash -s builtin
  cd ./KernelSU

  GIT_COMMIT_HASH=$(git rev-parse --short=8 HEAD)

  for i in {1..3}; do
    KSU_API_VERSION=$(curl -s "https://raw.githubusercontent.com/SukiSU-Ultra/SukiSU-Ultra/builtin/kernel/Kbuild" |
      grep -m1 "KSU_VERSION_API :=" |
      awk -F'= ' '{print $2}' |
      tr -d '[:space:]')
    [[ -n "${KSU_API_VERSION:-}" ]] && break || sleep 1
  done
  [[ -z "${KSU_API_VERSION:-}" ]] && KSU_API_VERSION="3.1.7"

  VERSION_DEFINITIONS=$'define get_ksu_version_full\nv\\$1-'"$GIT_COMMIT_HASH"$'@'"$REPO_OWNER_TAG"$'\nendef\n\nKSU_VERSION_API := '"$KSU_API_VERSION"$'\nKSU_VERSION_FULL := v'"$KSU_API_VERSION"$'-'"$GIT_COMMIT_HASH"$'@'"$REPO_OWNER_TAG"

  sed -i '/define get_ksu_version_full/,/endef/d' kernel/Kbuild
  sed -i '/KSU_VERSION_API :=/d' kernel/Kbuild
  sed -i '/KSU_VERSION_FULL :=/d' kernel/Kbuild

  awk -v def="$VERSION_DEFINITIONS" '
    /REPO_OWNER :=/ {print; print def; inserted=1; next}
    1
    END {if (!inserted) print def}
  ' kernel/Kbuild > kernel/Kbuild.tmp && mv kernel/Kbuild.tmp kernel/Kbuild

  KSU_VERSION=$(expr $(git rev-list --count main) + 37185 2>/dev/null || echo 114514)
  echo "KSUVER=$KSU_VERSION" >> "$GITHUB_ENV"
  echo "KSU_TYPE_NAME=SukiSU" >> "$GITHUB_ENV"
  echo "KSU_TYPE_NAME_RELEASE=SukiSU Ultra" >> "$GITHUB_ENV"

elif [[ "$KSU_TYPE" == "resukisu" ]]; then
  echo "正在配置ReSukiSU..."
  curl -LSs "https://raw.githubusercontent.com/ReSukiSU/ReSukiSU/refs/heads/main/kernel/setup.sh" | bash -s main
  echo "CONFIG_KSU_FULL_NAME_FORMAT=\"%TAG_NAME%-%COMMIT_SHA%@${REPO_OWNER_TAG}\"" >> ./common/arch/arm64/configs/gki_defconfig
  cd ./KernelSU
  KSU_VERSION=$(expr $(git rev-list --count main) + 30700 2>/dev/null || echo 114514)
  echo "KSUVER=$KSU_VERSION" >> "$GITHUB_ENV"
  echo "KSU_TYPE_NAME=ReSukiSU" >> "$GITHUB_ENV"
  echo "KSU_TYPE_NAME_RELEASE=ReSukiSU" >> "$GITHUB_ENV"

elif [[ "$KSU_TYPE" == "ksunext" ]]; then
  echo "正在配置KernelSU Next..."
  curl -LSs "https://raw.githubusercontent.com/pershoot/KernelSU-Next/refs/heads/dev-susfs/kernel/setup.sh" | bash -s dev-susfs
  cd KernelSU-Next
  rm -rf .git
  KSU_VERSION=$(expr $(curl -sI "https://api.github.com/repos/pershoot/KernelSU-Next/commits?sha=dev&per_page=1" | grep -i "link:" | sed -n 's/.*page=\([0-9]*\)>; rel="last".*/\1/p') "+" 30000)
  sed -i "s/KSU_VERSION_FALLBACK := 1/KSU_VERSION_FALLBACK := $KSU_VERSION/g" kernel/Kbuild || true
  KSU_GIT_TAG=$(curl -sL "https://api.github.com/repos/KernelSU-Next/KernelSU-Next/tags" | grep -o '"name": *"[^"]*"' | head -n 1 | sed 's/"name": "//;s/"//')
  sed -i "s/KSU_VERSION_TAG_FALLBACK := v0.0.1/KSU_VERSION_TAG_FALLBACK := $KSU_GIT_TAG/g" kernel/Kbuild || true

  cd ../common/drivers/kernelsu
  wget "https://github.com/$GITHUB_REPOSITORY/raw/refs/heads/$GITHUB_REF_NAME/other_patch/apk_sign.patch"
  patch -p2 -N -F 3 < apk_sign.patch || true

  echo "KSUVER=$KSU_VERSION" >> "$GITHUB_ENV"
  echo "KSU_TYPE_NAME=KSUNext" >> "$GITHUB_ENV"
  echo "KSU_TYPE_NAME_RELEASE=KernelSU Next" >> "$GITHUB_ENV"

elif [[ "$KSU_TYPE" == "ksu" ]]; then
  echo "正在配置原版 KernelSU (tiann/KernelSU)..."
  curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/refs/heads/main/kernel/setup.sh" | bash -s main
  cd ./KernelSU
  KSU_VERSION=$(expr $(curl -sI "https://api.github.com/repos/tiann/KernelSU/commits?sha=main&per_page=1" | grep -i "link:" | sed -n 's/.*page=\([0-9]*\)>; rel="last".*/\1/p') "+" 30000)
  sed -i "s/DKSU_VERSION=16/DKSU_VERSION=${KSU_VERSION}/" kernel/Kbuild || true

  echo "KSUVER=$KSU_VERSION" >> "$GITHUB_ENV"
  echo "KSU_TYPE_NAME=KSU" >> "$GITHUB_ENV"
  echo "KSU_TYPE_NAME_RELEASE=KernelSU (Official)" >> "$GITHUB_ENV"

else
  echo "已选择无内置KernelSU模式，跳过KernelSU配置..."
  echo "KSUVER=none" >> "$GITHUB_ENV"
  echo "KSU_TYPE_NAME=none" >> "$GITHUB_ENV"
  echo "KSU_TYPE_NAME_RELEASE=无内置KSU" >> "$GITHUB_ENV"
fi
