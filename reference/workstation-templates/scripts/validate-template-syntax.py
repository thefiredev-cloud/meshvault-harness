#!/usr/bin/env python3
"""Validate JSON, TOML, and YAML template syntax."""

from __future__ import annotations

import json
import shutil
import subprocess
import sys
import tomllib
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def files_with_suffix(*suffixes: str) -> list[Path]:
    ignored = {".git", "node_modules"}
    paths: list[Path] = []
    for path in ROOT.rglob("*"):
        if not path.is_file():
            continue
        if any(part in ignored for part in path.parts):
            continue
        if path.suffix.lower() in suffixes:
            paths.append(path)
    return sorted(paths)


def validate_json(path: Path) -> None:
    json.loads(path.read_text(encoding="utf-8"))


def validate_toml(path: Path) -> None:
    tomllib.loads(path.read_text(encoding="utf-8"))


def validate_yaml(paths: list[Path]) -> None:
    ruby = shutil.which("ruby")
    if not ruby:
        print("validate-template-syntax: ruby unavailable, skipping YAML parse")
        return

    command = [
        ruby,
        "-e",
        "require 'yaml'; ARGV.each { |path| YAML.load_file(path) }",
        *[str(path) for path in paths],
    ]
    subprocess.run(command, check=True)


def main() -> int:
    findings: list[str] = []

    for path in files_with_suffix(".json"):
        try:
            validate_json(path)
        except Exception as exc:  # noqa: BLE001 - report parser exception verbatim.
            findings.append(f"{path.relative_to(ROOT)}: JSON parse failed: {exc}")

    for path in files_with_suffix(".toml"):
        try:
            validate_toml(path)
        except Exception as exc:  # noqa: BLE001 - report parser exception verbatim.
            findings.append(f"{path.relative_to(ROOT)}: TOML parse failed: {exc}")

    yaml_paths = files_with_suffix(".yaml", ".yml")
    if yaml_paths:
        try:
            validate_yaml(yaml_paths)
        except subprocess.CalledProcessError as exc:
            findings.append(f"YAML parse failed with exit code {exc.returncode}")

    if findings:
        print("validate-template-syntax: failed", file=sys.stderr)
        for finding in findings:
            print(finding, file=sys.stderr)
        return 1

    print("validate-template-syntax: passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
