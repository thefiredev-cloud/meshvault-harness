#!/usr/bin/env bash
# Shared helpers for install.sh, setup.sh and the `meshvault` CLI. Bash 3.2 compatible (macOS).
# shellcheck shell=bash

MV_HOME="${MESHVAULT_HOME:-$HOME/.meshvault}"
MV_PORT_DEFAULT=8484
MV_ALIAS="meshvault-local"

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  C_B=$'\033[1m'; C_G=$'\033[32m'; C_Y=$'\033[33m'; C_R=$'\033[31m'; C_D=$'\033[2m'; C_0=$'\033[0m'
else
  C_B=""; C_G=""; C_Y=""; C_R=""; C_D=""; C_0=""
fi

say()  { printf '%s\n' "$*"; }
step() { printf '\n%s==> %s%s\n' "$C_B" "$*" "$C_0"; }
ok()   { printf '%s ok%s  %s\n' "$C_G" "$C_0" "$*"; }
warn() { printf '%swarn%s  %s\n' "$C_Y" "$C_0" "$*" >&2; }
die()  { printf '%sfail%s  %s\n' "$C_R" "$C_0" "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

detect_os() {
  case "$(uname -s)" in
    Linux) echo linux ;;
    Darwin) echo darwin ;;
    *) echo unsupported ;;
  esac
}

detect_arch() {
  if [ "$(uname -s)" = "Darwin" ] && [ "$(sysctl -in hw.optional.arm64 2>/dev/null || true)" = "1" ]; then
    echo arm64; return
  fi
  case "$(uname -m)" in
    x86_64|amd64) echo x64 ;;
    arm64|aarch64) echo arm64 ;;
    *) uname -m ;;
  esac
}

# Usable RAM in whole GB: physical RAM, capped by a container memory limit when one is set.
ram_gb() {
  local kb=0 bytes lim
  if [ "$(uname -s)" = "Darwin" ]; then
    bytes=$(sysctl -n hw.memsize 2>/dev/null || echo 0)
    echo $(( bytes / 1073741824 )); return
  fi
  kb=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo 2>/dev/null || echo 0)
  bytes=$(( kb * 1024 ))
  for f in /sys/fs/cgroup/memory.max /sys/fs/cgroup/memory/memory.limit_in_bytes; do
    if [ -r "$f" ]; then
      lim=$(cat "$f" 2>/dev/null || echo max)
      case "$lim" in max|""|*[!0-9]*) ;; *) [ "$lim" -lt "$bytes" ] && bytes=$lim ;; esac
    fi
  done
  echo $(( bytes / 1073741824 ))
}

# Free disk space in GB for the filesystem holding $1 (created if missing).
free_gb() {
  mkdir -p "$1"
  df -Pk "$1" | awk 'NR==2 {print int($4/1048576)}'
}

sha256_of() {
  if have sha256sum; then sha256sum "$1" | awk '{print $1}'
  else shasum -a 256 "$1" | awk '{print $1}'; fi
}

# download URL DEST [SHA256]: resumable, verified, atomic.
download() {
  local url="$1" dest="$2" want="${3:-}" part="$2.part" got
  mkdir -p "$(dirname "$dest")"
  if [ -f "$dest" ] && [ -n "$want" ] && [ "$(sha256_of "$dest")" = "$want" ]; then
    ok "already downloaded: $(basename "$dest")"; return 0
  fi
  local prog="-sS"; [ -t 1 ] && prog="--progress-bar"
  curl -fL --retry 5 --retry-delay 3 --connect-timeout 20 -C - $prog -o "$part" "$url" \
    || die "download failed: $url"
  if [ -n "$want" ]; then
    got=$(sha256_of "$part")
    if [ "$got" != "$want" ]; then
      rm -f "$part"
      die "checksum mismatch for $(basename "$dest") (expected $want, got $got). Partial file removed; rerun to retry."
    fi
  fi
  mv "$part" "$dest"
}

# tsv_rows FILE: print non-comment, non-empty lines.
tsv_rows() { grep -vE '^(#|[[:space:]]*$)' "$1"; }

# Read config written by setup.sh.
load_config() {
  # shellcheck disable=SC1091
  [ -f "$MV_HOME/config.env" ] && . "$MV_HOME/config.env"
  MV_PORT="${MV_PORT:-$MV_PORT_DEFAULT}"
  return 0
}

server_url() { echo "http://127.0.0.1:${MV_PORT:-$MV_PORT_DEFAULT}"; }

server_healthy() { curl -fs --max-time 3 "$(server_url)/health" >/dev/null 2>&1; }

# OpenAI-compatible base URL the agents use (bundled server or your own endpoint).
api_base() { echo "${MV_BASE_URL:-http://127.0.0.1:${MV_PORT:-$MV_PORT_DEFAULT}/v1}"; }
