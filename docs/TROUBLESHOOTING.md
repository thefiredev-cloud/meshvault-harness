# Troubleshooting

Start with `meshvault doctor`. It checks the model, Hermes, OMP and skills and says what failed.

| Symptom | Cause and fix |
|---|---|
| `meshvault: command not found` | `~/.local/bin` is not on PATH in this terminal. Open a new terminal or `export PATH="$HOME/.local/bin:$PATH"`. |
| Installer says missing libraries | Run the `sudo apt-get install -y libatomic1 libgomp1` line it prints (Fedora: `dnf install libatomic libgomp`), then rerun. |
| Download stops or checksum mismatch | Rerun the installer. Downloads resume; a bad file is deleted and fetched again. |
| Hermes reply takes minutes | CPU-only machine reading Hermes's long prompt. Wait for the first reply, later ones are faster. Use the smaller toolset (`hermes tools list`), a smaller model, `meshvault ask`, or Apple Silicon / a GPU (`--gpu vulkan`). |
| Hermes says the context window is too small | Hermes needs 64000 tokens. Keep `--ctx 65536`. If you use `--endpoint`, start that server with a 64K context. |
| Model server will not start | `meshvault logs`. Usually out of memory: `meshvault model use qwen3-1.7b`. |
| Port 8484 is in use | Reinstall with `--port 8585` or edit `MV_PORT` in `~/.meshvault/config.env` and run `meshvault restart`, then `hermes config set model.base_url http://127.0.0.1:8585/v1`. |
| OMP does not list the local model | You already had `~/.omp/agent/models.yml`. The installer printed the provider block to add; it is in `templates/omp-provider.yml`. |
| macOS: "cannot be opened because the developer cannot be verified" on llama-server | `xattr -dr com.apple.quarantine ~/.meshvault/runtime` then `meshvault restart`. |
| Skill not showing up | `meshvault skills sync`. A skill folder you made yourself with the same name is skipped on purpose. |

Still stuck: open an issue at https://github.com/thefiredev-cloud/meshvault-harness/issues with the output of `meshvault doctor` and `meshvault logs` (no secrets are in either). Done-for-you installs include email support.
