#!/usr/bin/env bash
# Static checks: syntax, shellcheck (if installed), catalog integrity, skill format, no fleet-specific strings.
set -eu
cd "$(dirname "$0")/.."
fail=0
note() { printf '%s\n' "$*"; }

for f in install.sh lib/*.sh bin/meshvault tests/*.sh; do
  bash -n "$f" || { note "syntax error: $f"; fail=1; }
done
note "bash -n: ok"

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck -S warning -e SC1091,SC2034,SC2086,SC2155,SC2015,SC2162 install.sh lib/*.sh bin/meshvault || fail=1
  note "shellcheck: done"
else
  note "shellcheck not installed: skipped"
fi

# Catalog: 7 tab-separated fields, 64-hex sha256, https URLs.
awk -F'\t' '!/^#/ && NF && (NF!=7 || $5 !~ /^[0-9a-f]{64}$/ || $4 !~ /^https:\/\//) {print "bad model row: " $1; bad=1} END {exit bad}' catalog/models.tsv || fail=1
awk -F'\t' '!/^#/ && NF && (NF!=5 || $4 !~ /^[0-9a-f]{64}$/ || $3 !~ /^https:\/\//) {print "bad runtime row: " $1; bad=1} END {exit bad}' catalog/runtime.tsv || fail=1
note "catalog: ok"

# Skills: SKILL.md with name + description frontmatter and an Approval Gate section.
for d in skills/*/; do
  s="${d}SKILL.md"
  [ -f "$s" ] || { note "missing $s"; fail=1; continue; }
  n="$(basename "$d")"
  grep -q "^name: $n\$" "$s" || { note "$s: name must be $n"; fail=1; }
  grep -q '^description: ' "$s" || { note "$s: no description"; fail=1; }
  grep -q 'Approval Gate' "$s" || { note "$s: no Approval Gate"; fail=1; }
done
note "skills: ok ($(ls -d skills/*/ | wc -l | tr -d ' '))"

# No fleet-specific hosts or personal paths in shipped files.
if grep -rIEn '100\.[0-9]+\.[0-9]+\.[0-9]+|\.ts\.net|pc-desktop|meshvault3|/home/[a-z]+/|tannermini' \
     --exclude-dir=.git --exclude=run.sh --exclude-dir=reference . ; then
  note "found fleet-specific strings"; fail=1
fi
note "no fleet strings: ok"

exit "$fail"
