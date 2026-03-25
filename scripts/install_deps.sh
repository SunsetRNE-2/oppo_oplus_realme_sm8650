#!/usr/bin/env bash
set -euo pipefail

sudo apt-mark hold firefox || true
sudo apt-mark hold libc-bin || true
sudo apt purge -y man-db || true
sudo rm -rf /var/lib/man-db/auto-update || true
sudo apt update
sudo apt-get install -y --no-install-recommends \
  binutils python-is-python3 libssl-dev libelf-dev ccache \
  aria2 unzip curl wget git zstd
