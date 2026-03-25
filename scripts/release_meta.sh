#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${KERNEL_SUFFIX:-}" ]]; then
  FULL_VERSION="${KERNEL_VERSION}.${SUB_VERSION}-${KERNEL_SUFFIX}"
else
  FULL_VERSION="${KERNEL_VERSION}.${SUB_VERSION}-${KERNEL_NAME}"
fi

TIME="$(TZ='Asia/Shanghai' date +'%y%m%d%H%M%S')"
TIME_FORM="$(TZ='Asia/Shanghai' date +'%Y-%m-%d %H:%M:%S')"
TAG_HEAD="OPPO-OPlus-Realme-build"

case "${KSU_TYPE:-none}" in
  sukisu) KSU_TYPENAME="SukiSU Ultra" ;;
  resukisu) KSU_TYPENAME="ReSukiSU" ;;
  ksunext) KSU_TYPENAME="KernelSU Next" ;;
  ksu) KSU_TYPENAME="KernelSU (Official)" ;;
  *) KSU_TYPENAME="无内置KSU" ;;
esac

BODY_FILE="${RUNNER_TEMP:-/tmp}/release_body.md"

cat > "$BODY_FILE" <<EOF
### 📱 欧加真 ${KSU_TYPENAME} ${PLATFORM_NAME} 通用内核 | 构建信息
- 内核版本号: ${FULL_VERSION}
- 编译时间: ${TIME_FORM}
- 机型：${DEVICE_DESC} ${KERNEL_VERSION}.${SUB_VERSION} 内核（${SOURCE_DESC}）
- KSU分支：${KSU_TYPENAME}
- susfs支持：${SUSFS_ENABLE}
- KPM支持 ：${KPM_ENABLE}
- LZ4支持：${LZ4_ENABLE}
- LZ4KD支持：${LZ4KD_ENABLE}
- 网络功能增强：${BETTER_NET}
- BBR/Brutal 等拥塞控制算法支持：${BBR_ENABLE}
- 三星SSG IO调度器支持：${SSG_ENABLE}
- Re-Kernel支持：${REKERNEL_ENABLE}
- 内核级基带保护支持：${BASEBAND_GUARD}

### ⏫️ 更新内容：
- 更新${KSU_TYPENAME}至最新版本（${KSUVER}）
- (预留)
EOF

cat <<EOF
FULL_VERSION=$FULL_VERSION
TIME=$TIME
TIME_FORM=$TIME_FORM
TAG_HEAD=$TAG_HEAD
KSU_TYPENAME=$KSU_TYPENAME
BODY_FILE=$BODY_FILE
EOF
