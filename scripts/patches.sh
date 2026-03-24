#!/usr/bin/env bash
set -euo pipefail

append_config() {
  local cfg_file="$1"
  local line="$2"
  echo "$line" >> "$cfg_file"
}

apply_dirty_cleanup() {
  local source_root="$1"
  rm -f "$source_root"/android/abi_gki_protected_exports_* || true

  for f in "$source_root/scripts/setlocalversion"; do
    sed -i 's/ -dirty//g' "$f"
    sed -i '$i res=$(echo "$res" | sed '\''s/-dirty//g'\'')' "$f"
  done
}

apply_kernel_name_suffix() {
  local source_root="$1"
  local final_suffix="$2"

  for f in "$source_root/scripts/setlocalversion"; do
    sed -i "\$s|echo \"\\\$res\"|echo \"-${final_suffix}\"|" "$f"
  done
}

apply_ksu_branch() {
  local workspace="$1"
  local ksu_type="$2"
  local defconfig_path="$3"

  cd "$workspace"

  case "$ksu_type" in
    sukisu)
      echo "正在配置SukiSU Ultra..."
      curl -LSs "https://raw.githubusercontent.com/ShirkNeko/SukiSU-Ultra/refs/heads/main/kernel/setup.sh" | bash -s builtin
      cd ./KernelSU

      local git_hash
      git_hash="$(git rev-parse --short=8 HEAD)"

      local api_ver=""
      for i in {1..3}; do
        api_ver="$(curl -s "https://raw.githubusercontent.com/SukiSU-Ultra/SukiSU-Ultra/builtin/kernel/Kbuild" | grep -m1 'KSU_VERSION_API :=' | awk -F'= ' '{print $2}' | tr -d '[:space:]')"
        [ -n "$api_ver" ] && break || sleep 1
      done
      [ -z "$api_ver" ] && api_ver="3.1.7"

      echo "KSU_API_VERSION=$api_ver" >> "$GITHUB_ENV"

      local version_defs
      version_defs=$'define get_ksu_version_full\nv\\$1-'"$git_hash"$'@cctv18\nendef\n\nKSU_VERSION_API := '"$api_ver"$'\nKSU_VERSION_FULL := v'"$api_ver"$'-'"$git_hash"$'@cctv18'

      sed -i '/define get_ksu_version_full/,/endef/d' kernel/Kbuild
      sed -i '/KSU_VERSION_API :=/d' kernel/Kbuild
      sed -i '/KSU_VERSION_FULL :=/d' kernel/Kbuild

      awk -v def="$version_defs" '
        /REPO_OWNER :=/ {print; print def; inserted=1; next}
        1
        END {if (!inserted) print def}
      ' kernel/Kbuild > kernel/Kbuild.tmp && mv kernel/Kbuild.tmp kernel/Kbuild

      local ksu_ver
      ksu_ver="$(expr "$(git rev-list --count main)" + 37185 2>/dev/null || echo 114514)"
      echo "KSUVER=$ksu_ver" >> "$GITHUB_ENV"
      echo "KSU_VERSION_OUTPUT=$ksu_ver" >> "$GITHUB_ENV"
      ;;
    resukisu)
      echo "正在配置ReSukiSU..."
      curl -LSs "https://raw.githubusercontent.com/ReSukiSU/ReSukiSU/refs/heads/main/kernel/setup.sh" | bash -s main
      echo 'CONFIG_KSU_FULL_NAME_FORMAT="%TAG_NAME%-%COMMIT_SHA%@cctv18"' >> "$defconfig_path"
      cd ./KernelSU

      local ksu_ver
      ksu_ver="$(expr "$(git rev-list --count main)" + 30700 2>/dev/null || echo 114514)"
      echo "KSUVER=$ksu_ver" >> "$GITHUB_ENV"
      echo "KSU_VERSION_OUTPUT=$ksu_ver" >> "$GITHUB_ENV"
      ;;
    ksunext)
      echo "正在配置KernelSU Next..."
      curl -LSs "https://raw.githubusercontent.com/pershoot/KernelSU-Next/refs/heads/dev-susfs/kernel/setup.sh" | bash -s dev-susfs
      cd KernelSU-Next
      rm -rf .git

      local ksu_ver
      ksu_ver="$(expr "$(curl -sI "https://api.github.com/repos/pershoot/KernelSU-Next/commits?sha=dev&per_page=1" | grep -i "link:" | sed -n 's/.*page=\([0-9]*\)>; rel="last".*/\1/p')" + 30000)"
      echo "KSUVER=$ksu_ver" >> "$GITHUB_ENV"
      echo "KSU_VERSION_OUTPUT=$ksu_ver" >> "$GITHUB_ENV"

      sed -i "s/KSU_VERSION_FALLBACK := 1/KSU_VERSION_FALLBACK := $ksu_ver/g" kernel/Kbuild

      local tag
      tag="$(curl -sL "https://api.github.com/repos/KernelSU-Next/KernelSU-Next/tags" | grep -o '"name": *"[^"]*"' | head -n 1 | sed 's/"name": "//;s/"//')"
      sed -i "s/KSU_VERSION_TAG_FALLBACK := v0.0.1/KSU_VERSION_TAG_FALLBACK := $tag/g" kernel/Kbuild

      cd ../common/drivers/kernelsu
      wget "https://github.com/$GITHUB_REPOSITORY/raw/refs/heads/$GITHUB_REF_NAME/other_patch/apk_sign.patch"
      patch -p2 -N -F 3 < apk_sign.patch || true
      ;;
    ksu)
      echo "正在配置原版 KernelSU..."
      curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/refs/heads/main/kernel/setup.sh" | bash -s main
      cd ./KernelSU

      local ksu_ver
      ksu_ver="$(expr "$(curl -sI "https://api.github.com/repos/tiann/KernelSU/commits?sha=main&per_page=1" | grep -i "link:" | sed -n 's/.*page=\([0-9]*\)>; rel="last".*/\1/p')" + 30000)"
      echo "KSUVER=$ksu_ver" >> "$GITHUB_ENV"
      echo "KSU_VERSION_OUTPUT=$ksu_ver" >> "$GITHUB_ENV"

      sed -i "s/DKSU_VERSION=16/DKSU_VERSION=${ksu_ver}/" kernel/Kbuild
      ;;
    none)
      echo "已选择无内置KernelSU模式，跳过KernelSU配置..."
      echo "KSUVER=0" >> "$GITHUB_ENV"
      echo "KSU_VERSION_OUTPUT=0" >> "$GITHUB_ENV"
      ;;
    *)
      echo "未知 ksu_type: $ksu_type" >&2
      return 1
      ;;
  esac
}

apply_susfs() {
  local workspace="$1"
  local android_version="$2"
  local kernel_main="$3"
  local ksu_type="$4"

  cd "$workspace"

  if [[ "$ksu_type" != "none" ]]; then
    git clone --depth=1 "https://github.com/cctv18/susfs4oki.git" susfs4ksu -b "oki-${android_version}-${kernel_main}"
    wget "https://github.com/$GITHUB_REPOSITORY/raw/refs/heads/$GITHUB_REF_NAME/other_patch/69_hide_stuff.patch" -O ./common/69_hide_stuff.patch
    cp "./susfs4ksu/kernel_patches/50_add_susfs_in_gki-${android_version}-${kernel_main}.patch" ./common/
    cp ./susfs4ksu/kernel_patches/fs/* ./common/fs/
    cp ./susfs4ksu/kernel_patches/include/linux/* ./common/include/linux/
    cd ./common
    patch -p1 < "50_add_susfs_in_gki-${android_version}-${kernel_main}.patch" || true
    patch -p1 -N -F 3 < 69_hide_stuff.patch || true
    cd ..
  else
    echo "已选择无内置KernelSU模式，跳过susfs配置..."
  fi

  if [[ "$ksu_type" == "ksu" ]]; then
    cp ./susfs4ksu/kernel_patches/KernelSU/10_enable_susfs_for_ksu.patch ./KernelSU/
    cd ./KernelSU
    patch -p1 < 10_enable_susfs_for_ksu.patch || true
  fi
}

apply_lz4_zstd_patch() {
  local workspace="$1"

  cd "$workspace"
  git clone --depth=1 "https://github.com/$GITHUB_REPOSITORY.git" -b "$GITHUB_REF_NAME" "$GITHUB_ACTOR"
  cp "./$GITHUB_ACTOR/zram_patch/001-lz4.patch" ./common/
  cp "./$GITHUB_ACTOR/zram_patch/lz4armv8.S" ./common/lib
  cp "./$GITHUB_ACTOR/zram_patch/002-zstd.patch" ./common/
  cd ./common
  git apply -p1 < 001-lz4.patch || true
  patch -p1 < 002-zstd.patch || true
}

apply_lz4kd_patch() {
  local workspace="$1"
  local kernel_main="$2"

  cd "$workspace"
  if [ ! -d "SukiSU_patch" ]; then
    git clone --depth=1 https://github.com/ShirkNeko/SukiSU_patch.git
  fi
  cd common
  cp -r ../SukiSU_patch/other/zram/lz4k/include/linux/* ./include/linux/
  cp -r ../SukiSU_patch/other/zram/lz4k/lib/* ./lib
  cp -r ../SukiSU_patch/other/zram/lz4k/crypto/* ./crypto
  cp "../SukiSU_patch/other/zram/zram_patch/${kernel_main}/lz4kd.patch" ./
  patch -p1 -F 3 < lz4kd.patch || true
}

apply_susfs_configs() {
  local defconfig_path="$1"
  append_config "$defconfig_path" "CONFIG_KSU_SUSFS=y"
  append_config "$defconfig_path" "CONFIG_KSU_SUSFS_HAS_MAGIC_MOUNT=y"
  append_config "$defconfig_path" "CONFIG_KSU_SUSFS_SUS_PATH=y"
  append_config "$defconfig_path" "CONFIG_KSU_SUSFS_SUS_MOUNT=y"
  append_config "$defconfig_path" "CONFIG_KSU_SUSFS_AUTO_ADD_SUS_KSU_DEFAULT_MOUNT=y"
  append_config "$defconfig_path" "CONFIG_KSU_SUSFS_AUTO_ADD_SUS_BIND_MOUNT=y"
  append_config "$defconfig_path" "CONFIG_KSU_SUSFS_SUS_KSTAT=y"
  append_config "$defconfig_path" "CONFIG_KSU_SUSFS_TRY_UMOUNT=y"
  append_config "$defconfig_path" "CONFIG_KSU_SUSFS_AUTO_ADD_TRY_UMOUNT_FOR_BIND_MOUNT=y"
  append_config "$defconfig_path" "CONFIG_KSU_SUSFS_SPOOF_UNAME=y"
  append_config "$defconfig_path" "CONFIG_KSU_SUSFS_ENABLE_LOG=y"
  append_config "$defconfig_path" "CONFIG_KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS=y"
  append_config "$defconfig_path" "CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG=y"
  append_config "$defconfig_path" "CONFIG_KSU_SUSFS_OPEN_REDIRECT=y"
  append_config "$defconfig_path" "CONFIG_KSU_SUSFS_SUS_MAP=y"
}

apply_base_configs() {
  local defconfig_path="$1"
  local ksu_type="$2"
  local kpm_enable="$3"
  local susfs_enable="$4"
  local lz4kd_enable="$5"

  append_config "$defconfig_path" "CONFIG_KSU=y"

  if [[ "$kpm_enable" == "builtin" && ( "$ksu_type" == "sukisu" || "$ksu_type" == "resukisu" ) ]]; then
    append_config "$defconfig_path" "CONFIG_KPM=y"
  fi

  if [[ "$susfs_enable" == "false" ]]; then
    append_config "$defconfig_path" "CONFIG_KSU_SUSFS=n"
  fi

  append_config "$defconfig_path" "CONFIG_TMPFS_XATTR=y"
  append_config "$defconfig_path" "CONFIG_TMPFS_POSIX_ACL=y"

  if [[ "$lz4kd_enable" == "true" ]]; then
    append_config "$defconfig_path" "CONFIG_ZSMALLOC=y"
    append_config "$defconfig_path" "CONFIG_CRYPTO_LZ4HC=y"
    append_config "$defconfig_path" "CONFIG_CRYPTO_LZ4K=y"
    append_config "$defconfig_path" "CONFIG_CRYPTO_LZ4KD=y"
    append_config "$defconfig_path" "CONFIG_CRYPTO_842=y"
  fi

  append_config "$defconfig_path" "CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=y"
  append_config "$defconfig_path" "CONFIG_HEADERS_INSTALL=n"
}

apply_better_net() {
  local workspace="$1"
  local defconfig_path="$2"

  append_config "$defconfig_path" "CONFIG_BPF_STREAM_PARSER=y"
  append_config "$defconfig_path" "CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y"
  append_config "$defconfig_path" "CONFIG_NETFILTER_XT_SET=y"
  append_config "$defconfig_path" "CONFIG_IP_SET=y"
  append_config "$defconfig_path" "CONFIG_IP_SET_MAX=65534"
  append_config "$defconfig_path" "CONFIG_IP_SET_BITMAP_IP=y"
  append_config "$defconfig_path" "CONFIG_IP_SET_BITMAP_IPMAC=y"
  append_config "$defconfig_path" "CONFIG_IP_SET_BITMAP_PORT=y"
  append_config "$defconfig_path" "CONFIG_IP_SET_HASH_IP=y"
  append_config "$defconfig_path" "CONFIG_IP_SET_HASH_IPMARK=y"
  append_config "$defconfig_path" "CONFIG_IP_SET_HASH_IPPORT=y"
  append_config "$defconfig_path" "CONFIG_IP_SET_HASH_IPPORTIP=y"
  append_config "$defconfig_path" "CONFIG_IP_SET_HASH_IPPORTNET=y"
  append_config "$defconfig_path" "CONFIG_IP_SET_HASH_IPMAC=y"
  append_config "$defconfig_path" "CONFIG_IP_SET_HASH_MAC=y"
  append_config "$defconfig_path" "CONFIG_IP_SET_HASH_NETPORTNET=y"
  append_config "$defconfig_path" "CONFIG_IP_SET_HASH_NET=y"
  append_config "$defconfig_path" "CONFIG_IP_SET_HASH_NETNET=y"
  append_config "$defconfig_path" "CONFIG_IP_SET_HASH_NETPORT=y"
  append_config "$defconfig_path" "CONFIG_IP_SET_HASH_NETIFACE=y"
  append_config "$defconfig_path" "CONFIG_IP_SET_LIST_SET=y"
  append_config "$defconfig_path" "CONFIG_IP6_NF_NAT=y"
  append_config "$defconfig_path" "CONFIG_IP6_NF_TARGET_MASQUERADE=y"

  cd "$workspace/common"
  wget "https://github.com/$GITHUB_REPOSITORY/raw/refs/heads/$GITHUB_REF_NAME/other_patch/config.patch"
  patch -p1 -F 3 < config.patch || true
}

apply_bbr_configs() {
  local defconfig_path="$1"
  local bbr_enable="$2"

  if [[ "$bbr_enable" == "false" ]]; then
    return 0
  fi

  append_config "$defconfig_path" "CONFIG_TCP_CONG_ADVANCED=y"
  append_config "$defconfig_path" "CONFIG_TCP_CONG_BBR=y"
  append_config "$defconfig_path" "CONFIG_TCP_CONG_CUBIC=y"
  append_config "$defconfig_path" "CONFIG_TCP_CONG_VEGAS=y"
  append_config "$defconfig_path" "CONFIG_TCP_CONG_NV=y"
  append_config "$defconfig_path" "CONFIG_TCP_CONG_WESTWOOD=y"
  append_config "$defconfig_path" "CONFIG_TCP_CONG_HTCP=y"
  append_config "$defconfig_path" "CONFIG_TCP_CONG_BRUTAL=y"

  if [[ "$bbr_enable" == "default" ]]; then
    append_config "$defconfig_path" "CONFIG_DEFAULT_TCP_CONG=bbr"
  else
    append_config "$defconfig_path" "CONFIG_DEFAULT_TCP_CONG=cubic"
  fi
}

apply_ssg_configs() {
  local defconfig_path="$1"
  append_config "$defconfig_path" "CONFIG_MQ_IOSCHED_SSG=y"
  append_config "$defconfig_path" "CONFIG_MQ_IOSCHED_SSG_CGROUP=y"
}

apply_rekernel_configs() {
  local defconfig_path="$1"
  append_config "$defconfig_path" "CONFIG_REKERNEL=y"
}

apply_baseband_guard() {
  local workspace="$1"
  local defconfig_path="$2"

  append_config "$defconfig_path" "CONFIG_BBG=y"
  cd "$workspace/common"
  curl -sSL https://github.com/cctv18/Baseband-guard/raw/master/setup.sh | bash
  sed -i '/^config LSM$/,/^help$/{ /^[[:space:]]*default/ { /baseband_guard/! s/selinux/selinux,baseband_guard/ } }' security/Kconfig
}

post_patch_build_config() {
  local workspace="$1"
  sed -i 's/check_defconfig//' "$workspace/common/build.config.gki"
}

prepare_faketime_wrappers() {
  local common_dir="$1"

  cd "$common_dir"
  wget "https://github.com/$GITHUB_REPOSITORY/raw/refs/heads/$GITHUB_REF_NAME/lib/libfakestat.so"
  wget "https://github.com/$GITHUB_REPOSITORY/raw/refs/heads/$GITHUB_REF_NAME/lib/libfaketimeMT.so"
  chmod 777 ./*.so

  export FAKESTAT="2025-05-25 12:00:00"
  export FAKETIME="@2025-05-25 13:00:00"

  local so_dir
  so_dir="$(pwd)"
  export PRELOAD_LIBS="$so_dir/libfakestat.so $so_dir/libfaketimeMT.so"

  cat > cc-wrapper <<EOF
#!/bin/bash
export LD_PRELOAD="$PRELOAD_LIBS"
export FAKESTAT="$FAKESTAT"
export FAKETIME="$FAKETIME"
ccache clang "\$@"
EOF

  cat > ld-wrapper <<EOF
#!/bin/bash
export LD_PRELOAD="$PRELOAD_LIBS"
export FAKESTAT="$FAKESTAT"
export FAKETIME="$FAKETIME"
ld.lld "\$@"
EOF

  chmod +x cc-wrapper ld-wrapper
}

apply_kpm_post_build() {
  local boot_dir="$1"
  local kpm_enable="$2"
  local ksu_type="$3"

  cd "$boot_dir"

  if [[ "$kpm_enable" == "builtin" && ( "$ksu_type" == "sukisu" || "$ksu_type" == "resukisu" ) ]]; then
    curl -LO https://github.com/SukiSU-Ultra/SukiSU_KernelPatch_patch/releases/latest/download/patch_linux
    chmod +x patch_linux
    ./patch_linux
    rm -f Image
    mv oImage Image
  fi

  if [[ "$kpm_enable" == "kpn" ]]; then
    wget https://github.com/KernelSU-Next/KPatch-Next/releases/latest/download/kptools-linux
    wget https://github.com/KernelSU-Next/KPatch-Next/releases/latest/download/kpimg-linux
    chmod +x ./kptools-linux
    ./kptools-linux -p -i ./Image -k ./kpimg-linux -o ./oImage
    rm -f Image
    mv oImage Image
  fi
}
