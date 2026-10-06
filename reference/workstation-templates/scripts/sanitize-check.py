#!/usr/bin/env python3
"""Fail if the public template appears to contain credentials."""

from __future__ import annotations

import os
import re
import sys
from pathlib import Path


ROOT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parents[1]

SKIP_DIRS = {
    ".git",
    "node_modules",
    "dist",
    "build",
    ".tmp",
}

SKIP_FILES = {
    Path("scripts/sanitize-check.py"),
    Path("LICENSE"),
}

TEXT_EXTENSIONS = {
    "",
    ".cfg",
    ".conf",
    ".example",
    ".gitignore",
    ".json",
    ".md",
    ".py",
    ".sh",
    ".toml",
    ".txt",
    ".yaml",
    ".yml",
}

SECRET_PATTERNS = [
    ("github_token", re.compile(r"\bgh[pousr]_[A-Za-z0-9_]{20,}\b")),
    ("github_fine_grained_token", re.compile(r"\bgithub_pat_[A-Za-z0-9_]{20,}\b")),
    ("openai_or_provider_key", re.compile(r"\bsk-[A-Za-z0-9_-]{20,}\b")),
    ("anthropic_key", re.compile(r"\bsk-ant-[A-Za-z0-9_-]{20,}\b")),
    ("telegram_bot_token", re.compile(r"\b[0-9]{8,12}:[A-Za-z0-9_-]{30,}\b")),
    ("aws_access_key_id", re.compile(r"\bAKIA[0-9A-Z]{16}\b")),
    ("slack_token", re.compile(r"\bxox[baprs]-[A-Za-z0-9-]{20,}\b")),
    ("stripe_live_secret", re.compile(r"\b(?:sk|rk)_live_[A-Za-z0-9]{16,}\b")),
    ("private_key_header", re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----")),
    ("jwt_like_secret", re.compile(r"\beyJ[A-Za-z0-9_-]{30,}\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\b")),
    (
        "database_url_with_credentials",
        re.compile(r"\b(?:postgres(?:ql)?|mysql|mongodb(?:\+srv)?|redis)://[^:\s'\"/@]+:[^@\s'\"]+@[^ \t\r\n'\"]+", re.I),
    ),
    ("npm_auth_token", re.compile(r"(?im)^\s*(?:_authToken|//[^:\s]+/:_authToken)\s*=\s*[^<${}\s#][^\s#]+")),
    ("signed_url_signature", re.compile(r"\b(?:X-Amz-Signature|X-Goog-Signature|AWSAccessKeyId|Signature|sig)=([A-Fa-f0-9]{24,}|[A-Za-z0-9%_-]{32,})\b")),
    ("cookie_header", re.compile(r"(?im)^\s*(?:cookie|set-cookie)\s*:\s*[^#\n]*(?:session|token|auth|jwt|sid)=[^;\s]{16,}")),
    # Negative lookbehind for `sha256:` / `sha512:` etc — a published integrity
    # digest is not a credential. Codex writes `trusted_hash = "sha256:<64 hex>"`
    # into config.toml for every hook it trusts, which is safe to commit.
    ("long_hex_secret", re.compile(r"(?<![a-zA-Z0-9])(?<!sha1:)(?<!sha256:)(?<!sha512:)(?<!md5:)\b[a-fA-F0-9]{64,}\b")),
]

ASSIGNMENT_RE = re.compile(
    r"""(?im)^[ \t]*["']?([A-Z0-9_.\-_]*(?:API[_-]?KEY|TOKEN|SECRET|PASSWORD|WEBHOOK|PRIVATE[_-]?KEY|CLIENT[_-]?SECRET|AUTH|DATABASE[_-]?URL|DSN)[A-Z0-9_.\-_]*)["']?[ \t]*[:=][ \t]*["']?([^"'\s#]+)"""
)

PLACEHOLDER_MARKERS = {
    "",
    "changeme",
    "change_me",
    "example",
    "placeholder",
    "replace_me",
    "set_in_env",
    "todo",
    "your_value_here",
}

# Keys that contain a credential-ish word but are never credentials. ASSIGNMENT_RE
# is case-insensitive, so `TOKEN` matches `max_tokens`/`total_input_tokens` and
# `AUTH` matches `author`/`first_author`. Anchored full-key match so a real
# `AUTH_TOKEN` or `AUTHOR_API_KEY` still trips the check.
NON_SECRET_KEY_RE = re.compile(
    r"""(?ix)^(
          (?:(?:max|min|num|total|input|output|cache|creation|read|prompt|
                completion|remaining|used|budget)_)+tokens?
        | tokens?(?:_(?:used|count|display|remaining|per_\w+))?
        | \w*author\w*
        | (?:token|auth)_uri          # public OAuth endpoints, not credentials
    )$"""
)

# Values that are an indirection, not a literal secret: `os.environ.get("X")`,
# `os.getenv("X")`, `process.env.X`, `System.getenv(...)`, or a bare identifier
# being passed through (e.g. `max_tokens=max_tokens,`).
ENV_INDIRECTION_RE = re.compile(
    r"""(?ix)^(
          os\.(?:environ(?:\.get)?|getenv)\b
        | process\.env\b
        | system\.getenv\b
        | secrets\.
        | [\w.]+\.get\(                # self.credentials.get('...'), cfg.get(...)
    )"""
)

# Literal values that are structurally incapable of being a leaked credential.
NON_SECRET_VALUE_MARKERS = {"none", "null", "nil", "undefined", "true", "false", "0"}

# A line that names its own hex run as a digest — publishing a checksum is the point.
# No leading \b — `_` is a word char, so CLIENT_SHA256S has no boundary before SHA.
HASH_CONTEXT_RE = re.compile(
    r"(?i)(?:^|[\W_])(?:sha1|sha256|sha384|sha512|md5|checksum|digest|integrity|trusted_hash|fingerprint)s?(?:$|[\W_])"
)

# Python/TS type annotations captured via the `key: Type` form, not assignments.
TYPE_ANNOTATION_RE = re.compile(
    r"(?ix)^(?:optional|list|dict|set|tuple|union|final|classvar|annotated)\[|"
    r"^(?:str|int|float|bool|bytes|any|object|string|number|boolean)$"
)

# `"client_secret": client_secret,` — passing a variable through, not a literal.
IDENTIFIER_PASSTHROUGH_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*[,)\]]?$")

# `expect.stringMatching(...)`, `cfg.lookup(...)` — a call expression, not a literal.
CALL_EXPRESSION_RE = re.compile(r"^[A-Za-z_][\w.]*\(")

# Any `scheme://` URL. Paired with an explicit `@` check so only userinfo-free
# URLs are treated as safe.
URL_NO_USERINFO_RE = re.compile(r"(?i)^[a-z][a-z0-9+.-]*://")


def is_text_file(path: Path) -> bool:
    return path.suffix.lower() in TEXT_EXTENSIONS


def is_placeholder(value: str) -> bool:
    cleaned = value.strip().strip('"').strip("'")
    lowered = cleaned.lower()

    if lowered in PLACEHOLDER_MARKERS:
        return True
    if cleaned.startswith("${"):
        return True
    if cleaned.startswith("<") and cleaned.endswith(">"):
        return True
    if "replace" in lowered or "placeholder" in lowered or "set_in" in lowered:
        return True
    if cleaned.endswith("=") and len(cleaned) <= 1:
        return True
    # `.env.example` convention: your_github_token, YOUR-API-KEY-HERE, etc.
    if lowered.startswith(("your_", "your-")):
        return True
    if lowered in NON_SECRET_VALUE_MARKERS:
        return True
    if TYPE_ANNOTATION_RE.match(cleaned):
        return True
    if IDENTIFIER_PASSTHROUGH_RE.match(cleaned):
        return True
    if CALL_EXPRESSION_RE.match(cleaned):
        return True
    # An env read or pass-through reference is an indirection, not a literal.
    if ENV_INDIRECTION_RE.match(cleaned):
        return True
    # A URL with no `@` carries no userinfo, so there is no credential to leak —
    # `mysql://host:port/db` is safe to commit. The dedicated
    # database_url_with_credentials pattern still catches `scheme://u:p@host`.
    if URL_NO_USERINFO_RE.match(cleaned) and "@" not in cleaned:
        return True
    return False


def iter_files(root: Path):
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        base = Path(dirpath)
        for filename in filenames:
            path = base / filename
            rel = path.relative_to(root)
            if rel in SKIP_FILES:
                continue
            if not is_text_file(path):
                continue
            yield path, rel


def main() -> int:
    findings: list[str] = []

    for path, rel in iter_files(ROOT):
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue

        lines = text.splitlines()

        for name, pattern in SECRET_PATTERNS:
            for match in pattern.finditer(text):
                line = text.count("\n", 0, match.start()) + 1
                # A long hex run whose own line declares it a digest/checksum is an
                # integrity value, not a credential (e.g. Codex's trusted_hash and
                # NODE_REPL_TRUSTED_BROWSER_CLIENT_SHA256S entries).
                line_text = lines[line - 1] if line - 1 < len(lines) else ""
                if name == "long_hex_secret" and HASH_CONTEXT_RE.search(line_text):
                    continue
                findings.append(f"{rel}:{line}: matched {name}")

        for match in ASSIGNMENT_RE.finditer(text):
            key = match.group(1)
            value = match.group(2)
            if NON_SECRET_KEY_RE.match(key):
                continue
            if is_placeholder(value):
                continue
            if len(value) < 10:
                continue
            line = text.count("\n", 0, match.start()) + 1
            findings.append(f"{rel}:{line}: non-placeholder secret-like assignment for {key}")

    if findings:
        print("sanitize-check: failed", file=sys.stderr)
        for finding in findings:
            print(finding, file=sys.stderr)
        return 1

    print("sanitize-check: passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
