#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:-kernel_workspace}"
DEFCONFIG_PATH="${2:-./common/arch/arm64/configs/gki_defconfig}"

cd "$WORKSPACE_DIR"

append_cfg() {
  echo "$1" >> "$DEFCONFIG_PATH"
}

if [[ "${BETTER_NET:-false}" == "true" ]]; then
  append_cfg "CONFIG_BPF_STREAM_PARSER=y"
  append_cfg "CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y"
  append_cfg "CONFIG_NETFILTER_XT_SET=y"
  append_cfg "CONFIG_IP_SET=y"
  append_cfg "CONFIG_IP_SET_MAX=65534"
  append_cfg "CONFIG_IP_SET_BITMAP_IP=y"
  append_cfg "CONFIG_IP_SET_BITMAP_IPMAC=y"
  append_cfg "CONFIG_IP_SET_BITMAP_PORT=y"
  append_cfg "CONFIG_IP_SET_HASH_IP=y"
  append_cfg "CONFIG_IP_SET_HASH_IPMARK=y"
  append_cfg "CONFIG_IP_SET_HASH_IPPORT=y"
  append_cfg "CONFIG_IP_SET_HASH_IPPORTIP=y"
  append_cfg "CONFIG_IP_SET_HASH_IPPORTNET=y"
  append_cfg "CONFIG_IP_SET_HASH_IPMAC=y"
  append_cfg "CONFIG_IP_SET_HASH_MAC=y"
  append_cfg "CONFIG_IP_SET_HASH_NETPORTNET=y"
  append_cfg "CONFIG_IP_SET_HASH_NET=y"
  append_cfg "CONFIG_IP_SET_HASH_NETNET=y"
  append_cfg "CONFIG_IP_SET_HASH_NETPORT=y"
  append_cfg "CONFIG_IP_SET_HASH_NETIFACE=y"
  append_cfg "CONFIG_IP_SET_LIST_SET=y"
  append_cfg "CONFIG_IP6_NF_NAT=y"
  append_cfg "CONFIG_IP6_NF_TARGET_MASQUERADE=y"
fi

if [[ "${BBR_ENABLE:-false}" != "false" ]]; then
  append_cfg "CONFIG_TCP_CONG_ADVANCED=y"
  append_cfg "CONFIG_TCP_CONG_BBR=y"
  append_cfg "CONFIG_TCP_CONG_CUBIC=y"
  append_cfg "CONFIG_TCP_CONG_VEGAS=y"
  append_cfg "CONFIG_TCP_CONG_NV=y"
  append_cfg "CONFIG_TCP_CONG_WESTWOOD=y"
  append_cfg "CONFIG_TCP_CONG_HTCP=y"
  append_cfg "CONFIG_TCP_CONG_BRUTAL=y"

  if [[ "${BBR_ENABLE:-false}" == "default" ]]; then
    append_cfg "CONFIG_DEFAULT_TCP_CONG=bbr"
  else
    append_cfg "CONFIG_DEFAULT_TCP_CONG=cubic"
  fi
fi

if [[ "${SSG_ENABLE:-false}" == "true" ]]; then
  append_cfg "CONFIG_MQ_IOSCHED_SSG=y"
  append_cfg "CONFIG_MQ_IOSCHED_SSG_CGROUP=y"
fi

if [[ "${REKERNEL_ENABLE:-false}" == "true" ]]; then
  append_cfg "CONFIG_REKERNEL=y"
fi

if [[ "${BASEBAND_GUARD:-false}" == "true" ]]; then
  append_cfg "CONFIG_BBG=y"
fi
