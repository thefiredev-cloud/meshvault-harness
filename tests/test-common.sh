#!/usr/bin/env bash
# Behavior tests for lib/common.sh: catalog parsing, port and URL resolution, checksummed download, helpers.
# Runs offline: downloads use file:// URLs. Exit 0 = all pass. Called by tests/run.sh.
set -u
cd "$(dirname "$0")/.."

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export MESHVAULT_HOME="$TMP/mv-home"
unset MV_PORT MV_BASE_URL
# shellcheck source=../lib/common.sh
. lib/common.sh

pass=0; fails=0
eq() { # eq NAME WANT GOT
  if [ "$2" = "$3" ]; then pass=$((pass + 1))
  else fails=$((fails + 1)); printf 'FAIL %s\n  want: %s\n  got:  %s\n' "$1" "$2" "$3"; fi
}
truthy() { # truthy NAME CMD...: passes when CMD exits 0
  local name="$1"; shift
  if "$@"; then pass=$((pass + 1)); else fails=$((fails + 1)); printf 'FAIL %s\n' "$name"; fi
}
falsy() { # falsy NAME CMD...: passes when CMD exits non-zero
  local name="$1"; shift
  if "$@"; then fails=$((fails + 1)); printf 'FAIL %s (expected failure)\n' "$name"; else pass=$((pass + 1)); fi
}

# --- tsv_rows: data rows only, order and tabs preserved
printf '# catalog header\n\nalpha\t1\thttps://a\n   \n# inline comment line\nbeta\t2\thttps://b\n\t\n' > "$TMP/cat.tsv"
eq "tsv_rows keeps data rows in order" \
  "$(printf 'alpha\t1\thttps://a\nbeta\t2\thttps://b')" "$(tsv_rows "$TMP/cat.tsv")"

# --- server_url and api_base: default port, MV_PORT override, MV_BASE_URL override
eq "server_url default port" "http://127.0.0.1:8484" "$(server_url)"
eq "api_base default /v1 on default port" "http://127.0.0.1:8484/v1" "$(api_base)"
eq "server_url honors MV_PORT" "http://127.0.0.1:9100" "$(MV_PORT=9100 server_url)"
eq "api_base follows MV_PORT" "http://127.0.0.1:9100/v1" "$(MV_PORT=9100 api_base)"
eq "api_base uses MV_BASE_URL verbatim" "https://llm.example/v1" "$(MV_BASE_URL=https://llm.example/v1 api_base)"
eq "api_base ignores empty MV_BASE_URL" "http://127.0.0.1:8484/v1" "$(MV_BASE_URL= api_base)"

# --- load_config: absent file keeps default; config.env sets the port
rm -rf "$MESHVAULT_HOME"; unset MV_PORT
load_config
eq "load_config without config.env defaults port" "8484" "${MV_PORT:-}"
mkdir -p "$MESHVAULT_HOME"; printf 'MV_PORT=9123\n' > "$MESHVAULT_HOME/config.env"
unset MV_PORT; load_config
eq "load_config reads MV_PORT from config.env" "9123" "${MV_PORT:-}"
eq "load_config result feeds server_url" "http://127.0.0.1:9123" "$(server_url)"
unset MV_PORT

# --- have: command lookup
truthy "have finds an installed command" have bash
falsy "have rejects a missing command" have definitely-not-a-real-command-xyz

# --- sha256_of: known digest of "abc"
printf 'abc' > "$TMP/abc.txt"
eq "sha256_of matches known digest" \
  "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad" "$(sha256_of "$TMP/abc.txt")"

# --- download: verified fetch, mismatch, and cache hit
printf 'payload-bytes' > "$TMP/src.bin"
good="$(sha256_of "$TMP/src.bin")"
dl_ok="$TMP/out/nested/src.bin"
download "file://$TMP/src.bin" "$dl_ok" "$good" >/dev/null 2>&1
eq "download writes verified file" "payload-bytes" "$(cat "$dl_ok" 2>/dev/null)"
truthy "download leaves no .part file on success" test ! -e "$dl_ok.part"

bad_dest="$TMP/out/bad.bin"
mm_out="$( (download "file://$TMP/src.bin" "$bad_dest" "0000000000000000000000000000000000000000000000000000000000000000") 2>&1 )"
mm_rc=$?
eq "download checksum mismatch exits non-zero" "1" "$mm_rc"
eq "download checksum mismatch names the error" "1" "$(printf '%s' "$mm_out" | grep -c 'checksum mismatch')"
truthy "download mismatch leaves no destination" test ! -e "$bad_dest"
truthy "download mismatch removes partial file" test ! -e "$bad_dest.part"

cache_dest="$TMP/out/cached.bin"
printf 'payload-bytes' > "$cache_dest"
download "file://$TMP/does-not-exist.bin" "$cache_dest" "$good" >/dev/null 2>&1
eq "download skips fetch when file already matches checksum" "0" "$?"

# --- free_gb: missing nested path reports its nearest existing parent
deep="$TMP/not/yet/created/deep"
eq "free_gb on missing path matches existing parent" "$(free_gb "$TMP")" "$(free_gb "$deep")"
case "$(free_gb "$deep")" in
  ''|*[!0-9]*) fails=$((fails + 1)); echo "FAIL free_gb returns a non-integer" ;;
  *) pass=$((pass + 1)) ;;
esac
truthy "free_gb creates nothing" test ! -e "$TMP/not"

# --- die: exit 1, message on stderr, nothing on stdout
die_out="$( (die "boom here") 2>"$TMP/die.err" )"
die_rc=$?
eq "die exits 1" "1" "$die_rc"
eq "die prints nothing on stdout" "" "$die_out"
eq "die writes message to stderr" "1" "$(grep -c 'boom here' "$TMP/die.err")"

echo "common tests: $pass passed, $fails failed"
[ "$fails" -eq 0 ]
