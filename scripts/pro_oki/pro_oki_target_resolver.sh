#!/usr/bin/env bash
set -euo pipefail

TARGET_MODE="${1:-${TARGET_MODE:-single}}"
KERNEL_VERSION_INPUT="${KERNEL_VERSION_FULL:-${KERNEL_VERSION_INPUT:-${KERNEL_VERSION:-}}}"
CUSTOM_TARGETS="${CUSTOM_TARGETS:-}"

SUPPORTED_VERSIONS=(
  "6.1.57"
  "6.1.75"
  "6.1.115"
  "6.1.118"
  "6.1.128"
  "6.1.134"
)

trim() {
  local s="$1"
  s="${s#${s%%[![:space:]]*}}"
  s="${s%${s##*[![:space:]]}}"
  printf '%s' "$s"
}

is_supported_version() {
  local ver="$1"
  local item
  for item in "${SUPPORTED_VERSIONS[@]}"; do
    [[ "$item" == "$ver" ]] && return 0
  done
  return 1
}

is_valid_version_format() {
  local ver="$1"
  [[ "$ver" =~ ^6\.1\.[0-9]+$ ]]
}

json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  printf '%s' "$s"
}

declare -a TARGETS=()

add_target() {
  local ver
  ver="$(trim "$1")"
  [[ -z "$ver" ]] && return 0

  if ! is_valid_version_format "$ver"; then
    echo "[pro_oki_target_resolver] error: invalid version format: $ver" >&2
    exit 1
  fi

  if ! is_supported_version "$ver"; then
    echo "[pro_oki_target_resolver] error: unsupported version: $ver" >&2
    exit 1
  fi

  local existing
  for existing in "${TARGETS[@]:-}"; do
    [[ "$existing" == "$ver" ]] && return 0
  done

  TARGETS+=("$ver")
}

case "$TARGET_MODE" in
  single)
    if [[ -z "$(trim "$KERNEL_VERSION_INPUT")" ]]; then
      echo "[pro_oki_target_resolver] error: single mode requires KERNEL_VERSION_FULL / KERNEL_VERSION_INPUT / KERNEL_VERSION" >&2
      exit 1
    fi
    add_target "$KERNEL_VERSION_INPUT"
    RELEASE_SCOPE_NAME="single-${KERNEL_VERSION_INPUT}"
    ;;
  all-sm8650)
    add_target "6.1.57"
    add_target "6.1.75"
    add_target "6.1.118"
    RELEASE_SCOPE_NAME="all-sm8650"
    ;;
  all-mtk)
    add_target "6.1.115"
    add_target "6.1.128"
    add_target "6.1.134"
    RELEASE_SCOPE_NAME="all-mtk"
    ;;
  all)
    add_target "6.1.57"
    add_target "6.1.75"
    add_target "6.1.115"
    add_target "6.1.118"
    add_target "6.1.128"
    add_target "6.1.134"
    RELEASE_SCOPE_NAME="all"
    ;;
  custom)
    if [[ -z "$(trim "$CUSTOM_TARGETS")" ]]; then
      echo "[pro_oki_target_resolver] error: custom mode requires CUSTOM_TARGETS" >&2
      exit 1
    fi
    IFS=',' read -r -a RAW_TARGETS <<< "$CUSTOM_TARGETS"
    for item in "${RAW_TARGETS[@]}"; do
      add_target "$item"
    done
    [[ ${#TARGETS[@]} -gt 0 ]] || { echo "[pro_oki_target_resolver] error: custom mode resolved no valid targets" >&2; exit 1; }
    RELEASE_SCOPE_NAME="custom"
    ;;
  *)
    echo "[pro_oki_target_resolver] error: unknown TARGET_MODE: $TARGET_MODE" >&2
    exit 1
    ;;
esac

[[ ${#TARGETS[@]} -gt 0 ]] || { echo "[pro_oki_target_resolver] error: no targets resolved" >&2; exit 1; }

MATRIX_JSON="["
for i in "${!TARGETS[@]}"; do
  ver="${TARGETS[$i]}"
  item="{\"kernel_version_full\":\"$(json_escape "$ver")\"}"
  [[ "$i" -gt 0 ]] && MATRIX_JSON+=","
  MATRIX_JSON+="$item"
done
MATRIX_JSON+="]"

emit_output() {
  cat <<EOF
matrix=$MATRIX_JSON
target_count=${#TARGETS[@]}
release_scope_name=$RELEASE_SCOPE_NAME
EOF
}

emit_output

if [[ "${PRO_OKI_WRITE_GITHUB_OUTPUT:-0}" == "1" && -n "${GITHUB_OUTPUT:-}" ]]; then
  emit_output >> "$GITHUB_OUTPUT"
fi
