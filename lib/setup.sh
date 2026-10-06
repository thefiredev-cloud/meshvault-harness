#!/usr/bin/env bash
# MeshVault Harness setup. Called by install.sh. No secrets are read, written or required.
# sudo is used only if a system library is missing, and only when you can grant it.
set -eu
set -o pipefail

HARNESS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=common.sh
. "$HARNESS_DIR/lib/common.sh"
ORIG_PATH="$PATH"

OPT_YES=0; OPT_DRY=0; OPT_MODEL=""; OPT_NO_MODEL=0; OPT_NO_HERMES=0; OPT_NO_OMP=0
OPT_NO_AUTOSTART=1; OPT_NO_START=0; OPT_NO_VERIFY=0; OPT_PRO=""; OPT_GPU="cpu"; OPT_PORT="$MV_PORT_DEFAULT"
OPT_CTX=65536; OPT_LLAMA=""; OPT_SKIP_SYSDEPS=0; OPT_FORCE=0; OPT_ENDPOINT=""; OPT_ENDPOINT_MODEL=""; OPT_FULL_TOOLS=0

usage() {
  cat <<EOF
MeshVault Harness installer

  install.sh [options]

  --yes, -y              Do not ask questions.
  --model ID             Pick a model: qwen3-1.7b, qwen3-4b-2507, qwen3-8b, qwen3-30b-a3b-2507 (default: by RAM).
  --gpu cpu|vulkan       Linux llama.cpp build. Default cpu. macOS always uses Metal.
  --llama-server PATH    Use your own llama-server binary instead of the pinned download.
  --endpoint URL         Skip the bundled model server and point Hermes/OMP at your own OpenAI-compatible
                         endpoint (for example http://127.0.0.1:11434/v1 for Ollama). Needs --endpoint-model.
  --endpoint-model NAME  Model name served by --endpoint.
  --port N               Local model port (default $MV_PORT_DEFAULT).
  --ctx N                Context window (default 65536; Hermes needs at least 64000).
  --autostart            Start the model at login.
  --no-hermes | --no-omp Skip that agent.
  --no-start             Do not start the model server after install.
  --no-verify            Skip the end-to-end check at the end.
  --pro FILE             Install the Pro skills pack (tar.gz you received after purchase).
  --skip-sysdeps         Do not check/install system libraries.
  --force                Install even if this machine is under the RAM minimum.
  --full-tools           Keep all Hermes toolsets on (default trims heavy ones for small local models).
  --dry-run              Print what would happen and change nothing.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --yes|-y) OPT_YES=1 ;;
    --model) OPT_MODEL="${2:?--model needs an ID}"; shift ;;
    --gpu) OPT_GPU="${2:?--gpu needs cpu|vulkan}"; shift ;;
    --llama-server) OPT_LLAMA="${2:?}"; shift ;;
    --endpoint) OPT_ENDPOINT="${2:?}"; OPT_NO_MODEL=1; shift ;;
    --endpoint-model) OPT_ENDPOINT_MODEL="${2:?}"; shift ;;
    --port) OPT_PORT="${2:?}"; shift ;;
    --ctx) OPT_CTX="${2:?}"; shift ;;
    --autostart) OPT_NO_AUTOSTART=0 ;;
    --no-autostart) OPT_NO_AUTOSTART=1 ;;
    --no-hermes) OPT_NO_HERMES=1 ;;
    --no-omp) OPT_NO_OMP=1 ;;
    --no-start) OPT_NO_START=1 ;;
    --no-verify) OPT_NO_VERIFY=1 ;;
    --pro) OPT_PRO="${2:?}"; shift ;;
    --skip-sysdeps) OPT_SKIP_SYSDEPS=1 ;;
    --force) OPT_FORCE=1 ;;
    --full-tools) OPT_FULL_TOOLS=1 ;;
    --dry-run) OPT_DRY=1 ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; die "unknown option: $1" ;;
  esac
  shift
done

run() { if [ "$OPT_DRY" = 1 ]; then say "  [dry-run] $*"; else "$@"; fi; }
# run_logged LOGFILE CMD...: stream everything to LOGFILE, show the last lines only on failure. Honors --dry-run.
run_logged() {
  local log="$1"; shift
  if [ "$OPT_DRY" = 1 ]; then say "  [dry-run] $*"; return 0; fi
  mkdir -p "$(dirname "$log")"
  if "$@" </dev/null >"$log" 2>&1; then return 0; fi
  tail -n 20 "$log" | sed 's/^/    | /' >&2
  return 1
}

OS="$(detect_os)"; ARCH="$(detect_arch)"
[ "$OS" != unsupported ] || die "unsupported OS: $(uname -s). Linux and macOS only (Windows: use WSL2)."
case "$ARCH" in x64|arm64) ;; *) die "unsupported CPU: $ARCH" ;; esac
[ "$(id -u)" != 0 ] || warn "running as root. A normal user account is recommended; everything installs under \$HOME."

echo "${C_B}MeshVault Harness${C_0}  $(cat "$HARNESS_DIR/VERSION" 2>/dev/null || echo dev)"
say "Hermes + OMP + a local model + skills. Everything installs under your home folder."

# ---------------------------------------------------------------- prerequisites
step "Checking this machine"
for t in curl git tar; do have "$t" || die "$t is required. Install it first (Ubuntu/Debian: sudo apt-get install -y curl git; macOS: xcode-select --install)."; done
RAM="$(ram_gb)"
ok "$OS/$ARCH, ${RAM} GB usable RAM"

sysdeps_linux() {
  local missing=()
  # node (used by Hermes) needs libatomic; the llama.cpp CPU build needs libgomp.
  # Read the whole cache first: `ldconfig -p | grep -q` makes ldconfig die of SIGPIPE on a big cache,
  # and under pipefail that reported installed libraries as missing.
  local libs; libs="$(ldconfig -p 2>/dev/null || true)"
  grep -q 'libatomic.so.1' <<<"$libs" || missing+=(libatomic)
  grep -q 'libgomp.so.1' <<<"$libs"   || missing+=(libgomp)
  [ "${#missing[@]}" -eq 0 ] && { ok "system libraries present"; return 0; }
  local cmd=""
  if have apt-get; then cmd="apt-get install -y libatomic1 libgomp1"
  elif have dnf; then cmd="dnf install -y libatomic libgomp"
  elif have pacman; then cmd="pacman -S --needed --noconfirm gcc-libs"
  else warn "missing ${missing[*]}; install your distro's libatomic and libgomp packages."; return 0; fi
  if [ "$OPT_DRY" = 1 ]; then say "  [dry-run] sudo $cmd"; return 0; fi
  if [ "$(id -u)" = 0 ]; then $cmd >/dev/null
  elif have sudo && sudo -n true 2>/dev/null; then sudo $cmd >/dev/null
  elif have sudo && [ -t 0 ]; then say "Needs admin rights to install: ${missing[*]}"; sudo $cmd >/dev/null
  else die "missing system libraries (${missing[*]}). Run as an admin: sudo $cmd   then rerun this installer."; fi
  ok "installed ${missing[*]}"
}
if [ "$OS" = linux ] && [ "$OPT_SKIP_SYSDEPS" = 0 ]; then sysdeps_linux; fi

# ---------------------------------------------------------------- runtime + model
MODEL_ID=""; MODEL_FILE=""
if [ "$OPT_NO_MODEL" = 1 ]; then
  [ -n "$OPT_ENDPOINT" ] && [ -n "$OPT_ENDPOINT_MODEL" ] || die "--endpoint needs --endpoint-model NAME"
  step "Using your own model endpoint"
  ok "$OPT_ENDPOINT  model=$OPT_ENDPOINT_MODEL"
else
  step "Local model runtime (llama.cpp)"
  LLAMA_DIR=""
  if [ -n "$OPT_LLAMA" ]; then
    [ -x "$OPT_LLAMA" ] || die "--llama-server $OPT_LLAMA is not executable"
    ok "using your llama-server: $OPT_LLAMA"
  else
    plat="$OS-$ARCH"; [ "$OS" = linux ] && [ "$OPT_GPU" = vulkan ] && [ "$ARCH" = x64 ] && plat="$plat-vulkan"
    row="$(tsv_rows "$HARNESS_DIR/catalog/runtime.tsv" | awk -F'\t' -v p="$plat" '$1==p')"
    [ -n "$row" ] || die "no pinned llama.cpp build for $plat. Install llama.cpp yourself and pass --llama-server PATH."
    IFS=$'\t' read -r _ tag url sha _ <<<"$row"
    LLAMA_DIR="$MV_HOME/runtime/llama.cpp-$tag-$plat"
    if [ -x "$LLAMA_DIR/llama-server" ]; then ok "llama.cpp $tag already installed"
    else
      say "Downloading llama.cpp $tag ($plat)"
      if [ "$OPT_DRY" = 1 ]; then say "  [dry-run] download $url"; else
        download "$url" "$MV_HOME/runtime/$tag-$plat.tar.gz" "$sha"
        rm -rf "$LLAMA_DIR.tmp"; mkdir -p "$LLAMA_DIR.tmp"
        tar -xzf "$MV_HOME/runtime/$tag-$plat.tar.gz" -C "$LLAMA_DIR.tmp"
        inner="$(find "$LLAMA_DIR.tmp" -maxdepth 2 -name llama-server -print -quit)"
        [ -n "$inner" ] || die "llama-server not found in the downloaded archive"
        mv "$(dirname "$inner")" "$LLAMA_DIR"; rm -rf "$LLAMA_DIR.tmp" "$MV_HOME/runtime/$tag-$plat.tar.gz"
        ok "llama.cpp $tag installed"
      fi
    fi
    run ln -sfn "$LLAMA_DIR" "$MV_HOME/runtime/current"
  fi

  step "Choosing a model"
  cat_file="$HARNESS_DIR/catalog/models.tsv"
  if [ -n "$OPT_MODEL" ]; then
    row="$(tsv_rows "$cat_file" | awk -F'\t' -v id="$OPT_MODEL" '$1==id')"
    [ -n "$row" ] || die "unknown model '$OPT_MODEL'. Options: $(tsv_rows "$cat_file" | cut -f1 | tr '\n' ' ')"
  else
    row=""
    while IFS= read -r line; do
      min="$(printf '%s' "$line" | cut -f2)"
      [ "$RAM" -ge "$min" ] && row="$line"
    done < <(tsv_rows "$cat_file")
    if [ -z "$row" ]; then
      [ "$OPT_FORCE" = 1 ] || die "this machine has ${RAM} GB RAM; the smallest supported setup needs 8 GB (Hermes wants a 64K context window). Use --force to try anyway, or --endpoint to use a model running elsewhere."
      row="$(tsv_rows "$cat_file" | head -n1)"
    fi
  fi
  IFS=$'\t' read -r MODEL_ID min MODEL_FILE murl msha mbytes mnote <<<"$row"
  ok "$MODEL_ID: $mnote"
  need=$(( mbytes / 1073741824 + 3 ))
  have_gb="$(free_gb "$MV_HOME")"
  [ "$have_gb" -ge "$need" ] || die "need about ${need} GB free in $MV_HOME, have ${have_gb} GB."
  if [ "$OPT_YES" = 0 ] && [ -t 0 ] && [ "$OPT_DRY" = 0 ]; then
    printf 'Download %s (%s GB) now? [Y/n] ' "$MODEL_ID" "$(( mbytes / 1000000000 ))"; read -r ans
    case "$ans" in n|N|no) die "cancelled" ;; esac
  fi
  say "Downloading $MODEL_FILE (resumable; rerun the installer if your connection drops)"
  if [ "$OPT_DRY" = 1 ]; then say "  [dry-run] download $murl"; else download "$murl" "$MV_HOME/models/$MODEL_FILE" "$msha"; ok "model verified (sha256)"; fi
fi

# ---------------------------------------------------------------- config + CLI
step "Writing config"
if [ "$OPT_DRY" = 0 ]; then
  mkdir -p "$MV_HOME" "$HOME/.local/bin"
  if [ "$OPT_NO_MODEL" = 1 ]; then
    cat > "$MV_HOME/config.env" <<EOF
MV_MODE=endpoint
MV_BASE_URL=$OPT_ENDPOINT
MV_MODEL_NAME=$OPT_ENDPOINT_MODEL
MV_PORT=$OPT_PORT
EOF
  else
    cat > "$MV_HOME/config.env" <<EOF
MV_MODE=bundled
MV_MODEL_ID=$MODEL_ID
MV_MODEL_FILE=$MODEL_FILE
MV_PORT=$OPT_PORT
MV_CTX=$OPT_CTX
MV_LLAMA_SERVER=$OPT_LLAMA
MV_BASE_URL=http://127.0.0.1:$OPT_PORT/v1
MV_MODEL_NAME=$MV_ALIAS
EOF
  fi
  ln -sfn "$HARNESS_DIR/bin/meshvault" "$HOME/.local/bin/meshvault"
  ok "config at $MV_HOME/config.env; CLI at ~/.local/bin/meshvault"
fi
export PATH="$HOME/.local/bin:$PATH"
case ":$ORIG_PATH:" in *":$HOME/.local/bin:"*) ;; *)
  NEED_PATH_NOTE=1 ;; esac

# ---------------------------------------------------------------- start model
# shellcheck disable=SC1091
[ "$OPT_DRY" = 1 ] || . "$MV_HOME/config.env"
if [ "$OPT_NO_MODEL" = 0 ] && [ "$OPT_NO_START" = 0 ] && [ "$OPT_DRY" = 0 ]; then
  step "Starting the local model"
  "$HARNESS_DIR/bin/meshvault" start
fi
BASE_URL="http://127.0.0.1:$OPT_PORT/v1"; MODEL_NAME="$MV_ALIAS"
[ "$OPT_NO_MODEL" = 1 ] && { BASE_URL="$OPT_ENDPOINT"; MODEL_NAME="$OPT_ENDPOINT_MODEL"; }

# ---------------------------------------------------------------- hermes
if [ "$OPT_NO_HERMES" = 0 ]; then
  step "Hermes Agent"
  if have hermes; then ok "hermes already installed: $(hermes --version 2>/dev/null | head -n1)"
  else
    say "Installing Hermes Agent with the official installer (3 to 6 minutes; log: $MV_HOME/logs/hermes-install.log)"
    run_logged "$MV_HOME/logs/hermes-install.log" bash -c 'curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- --non-interactive --skip-browser --skip-computer-use' \
      || die "Hermes install failed. Log: $MV_HOME/logs/hermes-install.log"
  fi
  export PATH="$HOME/.local/bin:$PATH"
  if [ "$OPT_DRY" = 0 ]; then
    have hermes || die "hermes not found after install. Open a new terminal and rerun."
    hermes config set model.provider custom >/dev/null
    hermes config set model.base_url "$BASE_URL" >/dev/null
    hermes config set model.default "$MODEL_NAME" >/dev/null
    # Local CPU models can take minutes on the first long prompt.
    hermes config set HERMES_API_TIMEOUT 1800 >/dev/null 2>&1 || true
    if [ "$OPT_FULL_TOOLS" = 0 ] && [ "$OPT_NO_MODEL" = 0 ]; then
      # Hermes sends every enabled tool schema with each request. A lean set keeps the first
      # reply fast on small local models. Turn more on any time: hermes tools enable browser
      hermes tools disable browser vision image_gen tts computer_use delegation cronjob code_execution connections >/dev/null 2>&1 || true
      ok "Hermes toolset trimmed for local-model speed (hermes tools list to change)"
    fi
    ok "Hermes now uses $MODEL_NAME at $BASE_URL"
  fi
fi

# ---------------------------------------------------------------- omp
if [ "$OPT_NO_OMP" = 0 ]; then
  step "OMP (coding agent)"
  if have omp; then ok "omp already installed: $(omp --version 2>/dev/null | head -n1)"
  else
    say "Installing OMP with its official installer"
    run_logged "$MV_HOME/logs/omp-install.log" bash -c 'curl -fsSL https://raw.githubusercontent.com/can1357/oh-my-pi/main/scripts/install.sh | sh -s -- --binary' \
      || warn "OMP install failed (log: $MV_HOME/logs/omp-install.log). Hermes still works. Retry later with the command from https://github.com/can1357/oh-my-pi"
  fi
  if [ "$OPT_DRY" = 0 ] && have omp; then
    OMP_DIR="$HOME/.omp/agent"; mkdir -p "$OMP_DIR"
    if [ -f "$OMP_DIR/models.yml" ] && ! grep -q '^  meshvault-local:' "$OMP_DIR/models.yml"; then
      cp "$OMP_DIR/models.yml" "$OMP_DIR/models.yml.bak-meshvault"
      warn "you already have $OMP_DIR/models.yml; leaving it alone. Add this provider yourself:"
      sed -e "s|@BASE_URL@|$BASE_URL|" -e "s|@MODEL@|$MODEL_NAME|" "$HARNESS_DIR/templates/omp-provider.yml" | sed 's/^/    /'
    elif [ ! -f "$OMP_DIR/models.yml" ]; then
      { echo "providers:"; sed -e "s|@BASE_URL@|$BASE_URL|" -e "s|@MODEL@|$MODEL_NAME|" "$HARNESS_DIR/templates/omp-provider.yml"; } > "$OMP_DIR/models.yml"
      ok "OMP provider written to $OMP_DIR/models.yml"
    else ok "OMP provider already present"; fi
    if [ ! -f "$OMP_DIR/config.yml" ]; then
      printf 'modelRoles:\n  default: meshvault-local/%s\n' "$MODEL_NAME" > "$OMP_DIR/config.yml"
      ok "OMP default model set"
    else warn "$OMP_DIR/config.yml exists; select the model in OMP with /model (meshvault-local)."; fi
  fi
fi

# ---------------------------------------------------------------- skills
step "Skills"
if [ "$OPT_DRY" = 0 ]; then
  "$HARNESS_DIR/bin/meshvault" skills sync
  [ -z "$OPT_PRO" ] || "$HARNESS_DIR/bin/meshvault" pro install "$OPT_PRO"
fi

# ---------------------------------------------------------------- autostart
if [ "$OPT_NO_AUTOSTART" = 0 ] && [ "$OPT_NO_MODEL" = 0 ] && [ "$OPT_DRY" = 0 ]; then
  step "Autostart"
  "$HARNESS_DIR/bin/meshvault" autostart on || warn "autostart not available here"
fi

# ---------------------------------------------------------------- verify
if [ "$OPT_NO_VERIFY" = 0 ] && [ "$OPT_DRY" = 0 ]; then
  step "Checking everything works"
  "$HARNESS_DIR/bin/meshvault" doctor
fi

step "Done"
cat <<EOF
Try it:

  meshvault ask "In one sentence, what can you do on this machine?"
  hermes                 # chat with the agent (uses your local model)
  omp                    # coding agent in a project folder

Skills are installed. Ask Hermes: "give me a daily standup from the notes in ~/notes"
Heads up: on a CPU-only machine the first Hermes reply can take a few minutes while the model reads
Hermes's long prompt once. Later replies are much faster. Apple Silicon and GPUs start in seconds.
Manage: meshvault status | start | stop | doctor | model list | skills list

Free core is MIT. Pro skills pack and done-for-you install: https://github.com/thefiredev-cloud/meshvault-harness#tiers
EOF
if [ "${NEED_PATH_NOTE:-0}" = 1 ]; then
  echo
  warn "\$HOME/.local/bin is not on your PATH in this terminal. Open a new terminal, or run: export PATH=\"\$HOME/.local/bin:\$PATH\""
fi
