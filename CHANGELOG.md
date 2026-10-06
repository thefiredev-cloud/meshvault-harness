# Changelog

## 1.0.1 (2026-10-06)

Fix: the installer stopped with "missing system libraries (libatomic libgomp)" on desktop Linux machines that already had both. `ldconfig -p | grep -q` made `ldconfig` die of SIGPIPE on a large library cache, and `pipefail` turned that into a false "missing". The check now reads the cache once.

## 1.0.0 (2026-10-06)

First release. One-command installer for Linux and macOS; llama.cpp b11430 and Qwen3 model catalog (sha256-pinned); Hermes and OMP wired to the local model; 11 free skills; `meshvault` CLI (status, doctor, model, skills, pro, autostart, update); Pro pack installer; consolidated from six earlier repos.
