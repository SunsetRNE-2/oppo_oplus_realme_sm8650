#!/usr/bin/env bash
set -euo pipefail

generate_release_body() {
  local out_file="$1"
  local full_version="$2"
  local time_form="$3"
  local kernel_main="$4"
  local kernel_sub="$5"
  local ksu_typename="$6"
  local ksuver="$7"

  cat > "$out_file" <<EOF
### 📱 欧加真 ${ksu_typename} SM8650 通用内核 | 构建信息
- 内核版本号: ${full_version}
- 编译时间: ${time_form}
- 机型：欧加真骁龙8Gen3通用 ${kernel_main}.${kernel_sub} 内核（基于一加12 ${kernel_main}.${kernel_sub} Android 15 版官方OKI源码）
- KSU分支：${ksu_typename}
- susfs支持：${INPUT_SUSFS_ENABLE:-false}
- KPM支持 ：${INPUT_KPM_ENABLE:-false}
- LZ4支持：${INPUT_LZ4_ENABLE:-false}
- LZ4KD支持：${INPUT_LZ4KD_ENABLE:-false}
- 网络功能增强：${INPUT_BETTER_NET:-false}
- BBR/Brutal 等拥塞控制算法支持：${INPUT_BBR_ENABLE:-false}
- 三星SSG IO调度器支持：${INPUT_SSG_ENABLE:-false}
- Re-Kernel支持：${INPUT_REKERNEL_ENABLE:-false}
- 内核级基带保护支持：${INPUT_BASEBAND_GUARD:-false}
- SukiSU Ultra管理器下载：[SukiSU-Ultra](https://github.com/SukiSU-Ultra/SukiSU-Ultra/releases)
- KernelSU Next管理器下载：[KernelSU-Next](https://github.com/KernelSU-Next/KernelSU-Next/releases)
- KSU原版管理器下载：[KernelSU](https://github.com/tiann/KernelSU/releases)

### ⏫️ 更新内容：
- 更新${ksu_typename}至最新版本（${ksuver}）
- (预留)

### 📋 安装方法 | Installation Guide
1. 若你的手机已经安装了第三方Recovery（如TWRP)，可下载对应机型的AnyKernel刷机包后进入Recovery模式，通过Recovery刷入刷机包后重启设备；
2. 若你的手机之前已有 root 权限，可在手机上安装[HorizonKernelFlasher](https://github.com/libxzr/HorizonKernelFlasher/releases)，在HorizonKernelFlasher中刷入AnyKernel刷机包并重启；
3. 若你之前已刷入SukiSU Ultra内核，且SukiSU Ultra管理器已更新至最新版本，可在SukiSU Ultra管理器中直接刷入AnyKernel刷机包并重启；
4. 刷入无lz4kd补丁版的内核前若刷入过lz4kd补丁版的内核，为避免出错，请先关闭zram模块；
5. 由于KernelSU上游更新了元模块功能，最新版KSU管理器（包括除KernelSU Next以外的各分支）需要配合元模块(metamodule)才能正常挂载模块。目前的元模块包括[meta overlayfs](https://github.com/KernelSU-Modules-Repo/meta-overlayfs), [mountify](https://github.com/backslashxx/mountify), [meta magicmount](https://github.com/7a72/meta-magic_mount/), [meta magicmount rs](https://github.com/Tools-cx-app/meta-magic_mount/), [hybrid mount](https://github.com/YuzakiKokuban/meta-hybrid_mount)等。若你是第一次使用KSU或刚从旧版KSU管理器升级至新版，请先安装一个元模块，这样其他涉及系统挂载的模块才能正常运行；
6. KernelPatch Next（即KPN）是一个独立于KSU的KPM实现，可以运行在任意KSU/面具环境中（不适用于Apatch），且不能与(Re)SukiSU内置的kpm功能共同使用，使用前请保证你的内核没有内置的kpm实现/修补。

#### ※※※刷写内核有风险，为防止出现意外导致手机变砖，在刷入内核前请务必用[KernelFlasher](https://github.com/capntrips/KernelFlasher)等软件备份boot等关键启动分区!※※※
EOF
}
