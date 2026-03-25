#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${1:-kernel_workspace}"

WORKDIR="$(pwd)"
export PATH="/usr/lib/ccache:$PATH"
export PATH="$WORKDIR/$WORKSPACE_DIR/clang20/bin:$PATH"
export PATH="$WORKDIR/$WORKSPACE_DIR/build-tools/bin:$PATH"

CLANG_DIR="$WORKDIR/$WORKSPACE_DIR/clang20/bin"
echo "Clang版本: $($CLANG_DIR/clang --version | head -n 1)"
echo "LLD版本: $($CLANG_DIR/ld.lld --version | head -n 1)"

export CCACHE_LOGFILE="$WORKDIR/$WORKSPACE_DIR/ccache.log"
export CCACHE_COMPILERCHECK="none"
export CCACHE_BASEDIR="$WORKDIR"
export CCACHE_NOHASHDIR="true"
export CCACHE_HARDLINK="true"
export CCACHE_DIR="${CCACHE_DIR:?CCACHE_DIR not set}"
export CCACHE_MAXSIZE="${CCACHE_MAXSIZE:-3G}"

mkdir -p "$CCACHE_DIR"
echo "sloppiness = file_stat_matches,include_file_ctime,include_file_mtime,pch_defines,file_macro,time_macros" >> "$CCACHE_DIR/ccache.conf"

cd "$WORKSPACE_DIR/common"

wget "https://github.com/$GITHUB_REPOSITORY/raw/refs/heads/$GITHUB_REF_NAME/lib/libfakestat.so"
wget "https://github.com/$GITHUB_REPOSITORY/raw/refs/heads/$GITHUB_REF_NAME/lib/libfaketimeMT.so"
chmod 777 ./*.so

export FAKESTAT="2025-05-25 12:00:00"
export FAKETIME="@2025-05-25 13:00:00"
SO_DIR=$(pwd)
export PRELOAD_LIBS="$SO_DIR/libfakestat.so $SO_DIR/libfaketimeMT.so"

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

sudo rm -rf /usr/share/dotnet &
sudo rm -rf /usr/local/lib/android &
sudo rm -rf /opt/ghc &
sudo rm -rf /opt/hostedtoolcache/CodeQL &

make -j"$(nproc --all)" LLVM=1 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- CC="ccache clang" LD="ld.lld" HOSTLD=ld.lld O=out KCFLAGS+=-O2 KCFLAGS+=-Wno-error gki_defconfig &&
make -j"$(nproc --all)" LLVM=1 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- CC="$(pwd)/cc-wrapper" LD="$(pwd)/ld-wrapper" HOSTLD=ld.lld O=out KCFLAGS+=-O2 KCFLAGS+=-Wno-error Image

ccache -s
df -h
