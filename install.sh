#!/usr/bin/env bash
# MeshVault Harness: one-command installer (Linux and macOS).
#
#   curl -fsSL https://raw.githubusercontent.com/thefiredev-cloud/meshvault-harness/main/install.sh | bash
#
# Pass options after `bash -s --`, e.g.:  ... | bash -s -- --model qwen3-8b --autostart
# Read it first if you like: this file only fetches the repo and hands off to lib/setup.sh.
set -eu

REPO="${MESHVAULT_REPO:-https://github.com/thefiredev-cloud/meshvault-harness.git}"
MV_HOME="${MESHVAULT_HOME:-$HOME/.meshvault}"
REF="${MESHVAULT_REF:-}"

# Running from a checkout: use it as is.
SRC="${BASH_SOURCE[0]:-}"
if [ -n "$SRC" ] && [ -f "$(dirname "$SRC")/lib/setup.sh" ]; then
  exec bash "$(cd "$(dirname "$SRC")" && pwd)/lib/setup.sh" "$@"
fi

command -v git >/dev/null 2>&1 || { echo "git is required (Ubuntu/Debian: sudo apt-get install -y git; macOS: xcode-select --install)" >&2; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "curl is required" >&2; exit 1; }

# Default: newest release tag (v*); fall back to main.
if [ -z "$REF" ]; then
  REF="$(git ls-remote --tags --refs --sort=-v:refname "$REPO" 'v*' 2>/dev/null | awk 'NR==1 {sub("refs/tags/","",$2); print $2}')"
  REF="${REF:-main}"
fi

DEST="$MV_HOME/harness"
mkdir -p "$MV_HOME"
if [ -d "$DEST/.git" ]; then
  git -C "$DEST" fetch --quiet --tags origin "$REF" || git -C "$DEST" fetch --quiet --tags origin
  git -C "$DEST" checkout --quiet -f "$REF" 2>/dev/null || git -C "$DEST" checkout --quiet -f "origin/$REF"
else
  git clone --quiet "$REPO" "$DEST"
  git -C "$DEST" checkout --quiet "$REF"
fi
echo "MeshVault Harness $REF -> $DEST"
exec bash "$DEST/lib/setup.sh" "$@"
