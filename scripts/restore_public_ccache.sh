#!/usr/bin/env bash
set -euo pipefail

: "${CCACHE_DIR:?CCACHE_DIR not set}"

if [ -d "${CCACHE_DIR}" ] && [ "$(ls -A "${CCACHE_DIR}" 2>/dev/null)" ]; then
  echo "检测到本地已成功载入 ccache 缓存，跳过公共 ccache 拉取！"
  exit 0
fi

mkdir -p "${CCACHE_DIR}"
FILE_NAME="ccache-${KERNEL_VERSION}.${SUB_VERSION}.tar.zst"

if gh release download -p "$FILE_NAME" -R cctv18/public_ccache; then
  tar -I zstd -xf "$FILE_NAME" -C "${CCACHE_DIR}"
  echo "公共 ccache 恢复完成！"
else
  echo "公共 ccache 中未找到对应文件，将进行全量编译..."
fi
