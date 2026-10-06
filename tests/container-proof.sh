#!/usr/bin/env bash
# Clean-machine proof: fresh ubuntu:24.04, normal user with sudo, only curl/git/ca-certificates preinstalled
# (what a laptop already has). Runs the installer exactly as a customer would, then uses the result:
# local-model answer, Hermes answer, one skill, OMP answer.
#
#   tests/container-proof.sh local        # installer from this checkout (copied in)
#   tests/container-proof.sh url          # the real one-liner from GitHub main (or $MESHVAULT_PROOF_URL)
#
# Env: MEM (default 16g), CPUS (default 12), NAME (default mvh-proof), KEEP=1 keeps the container.
set -euo pipefail
MODE="${1:-local}"
NAME="${NAME:-mvh-proof}"; MEM="${MEM:-16g}"; CPUS="${CPUS:-12}"
HERE="$(cd "$(dirname "$0")/.." && pwd)"
URL="${MESHVAULT_PROOF_URL:-https://raw.githubusercontent.com/thefiredev-cloud/meshvault-harness/main/install.sh}"

docker rm -f "$NAME" >/dev/null 2>&1 || true
docker run -d --name "$NAME" --memory "$MEM" --cpus "$CPUS" ubuntu:24.04 sleep infinity >/dev/null
trap '[ "${KEEP:-0}" = 1 ] || docker rm -f "$NAME" >/dev/null 2>&1' EXIT

echo "### clean machine"
docker exec "$NAME" bash -lc 'apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq curl git ca-certificates sudo >/dev/null 2>&1
  useradd -m -s /bin/bash alice && echo "alice ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/alice
  . /etc/os-release; echo "$PRETTY_NAME, $(nproc) cpus, $(free -g | awk "/Mem:/ {print \$2}") GB (host view)"; cat /sys/fs/cgroup/memory.max'

echo "### install"
if [ "$MODE" = local ]; then
  docker cp "$HERE" "$NAME:/home/alice/meshvault-harness"
  docker exec "$NAME" chown -R alice:alice /home/alice/meshvault-harness
  docker exec -u alice -w /home/alice "$NAME" bash -lc './meshvault-harness/install.sh --yes ${INSTALL_ARGS:-}'
else
  docker exec -u alice -w /home/alice "$NAME" bash -lc "curl -fsSL $URL | bash -s -- --yes \${INSTALL_ARGS:-}"
fi

U="docker exec -u alice -w /home/alice $NAME bash -lc"
echo; echo "### use it 1/4: first answer straight from the local model"
$U 'export PATH=$HOME/.local/bin:$PATH; time meshvault ask "In one sentence, what is 17 times 3, and why is a local model private?"'

echo; echo "### use it 2/4: Hermes answers using the local model"
$U 'export PATH=$HOME/.local/bin:$PATH; time hermes chat -q "Reply with exactly: HERMES LOCAL OK" -Q 2>&1 | tail -n 8'

echo; echo "### use it 3/4: run one skill (daily-standup) on sample notes"
$U 'export PATH=$HOME/.local/bin:$PATH; meshvault skills list; mkdir -p ~/notes; cp ~/.meshvault/harness/examples/daily-standup-sample.md ~/notes/ 2>/dev/null || cp ~/meshvault-harness/examples/daily-standup-sample.md ~/notes/; time hermes chat -s daily-standup -q "Use the daily-standup skill on the file ~/notes/daily-standup-sample.md and give me the brief." -Q 2>&1 | tail -n 25'

echo; echo "### use it 4/4: OMP answers using the local model"
$U 'export PATH=$HOME/.local/bin:$PATH; cd ~/notes && time omp -p --no-session --no-tools --no-lsp --model meshvault-local/meshvault-local "Reply with exactly: OMP LOCAL OK" 2>&1 | tail -n 8'

echo; echo "### doctor"
$U 'export PATH=$HOME/.local/bin:$PATH; meshvault doctor'
echo "### proof complete"
