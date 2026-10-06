from __future__ import annotations

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "sanitize-check.py"


class SanitizeCheckTests(unittest.TestCase):
    def run_scan(self, files: dict[str, str]) -> subprocess.CompletedProcess[str]:
        with tempfile.TemporaryDirectory() as tmp:
            base = Path(tmp)
            for name, content in files.items():
                path = base / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(content, encoding="utf-8")

            return subprocess.run(
                [sys.executable, str(SCRIPT), str(base)],
                text=True,
                capture_output=True,
                check=False,
            )

    def test_allows_placeholders(self) -> None:
        result = self.run_scan(
            {
                "env.example": "\n".join(
                    [
                        "OPENAI_API_KEY=${OPENAI_API_KEY}",
                        "TOKEN=<value-from-secret-manager>",
                        "PASSWORD=REPLACE_ME",
                    ]
                )
            }
        )

        self.assertEqual(result.returncode, 0, result.stderr)

    def test_allows_token_count_identifiers(self) -> None:
        # ASSIGNMENT_RE is case-insensitive, so `TOKEN` matches `max_tokens` and
        # `AUTH` matches `author`. These are counts and names, never credentials.
        result = self.run_scan(
            {
                "adapter.py": "\n".join(
                    [
                        "max_tokens = min(kwargs.get('max_tokens', 1024) or 1024, 1024)",
                        "total_input_tokens=$((total_input_tokens + input_tokens))",
                        "total_cache_creation_tokens=0000000000",
                        "first_author = record.get('author_name_long')",
                    ]
                )
            }
        )

        self.assertEqual(result.returncode, 0, result.stderr)

    def test_allows_env_indirection_and_type_annotations(self) -> None:
        result = self.run_scan(
            {
                "config.py": "\n".join(
                    [
                        "api_key = os.environ.get('ANTHROPIC_API_KEY')",
                        "github_token: Optional[str] = None",
                        "refresh_token=self.credentials.get('refresh_token')",
                        "accessToken: expect.stringMatching(/^eyJ/),",
                    ]
                )
            }
        )

        self.assertEqual(result.returncode, 0, result.stderr)

    def test_allows_userinfo_free_urls_and_digests(self) -> None:
        result = self.run_scan(
            {
                "app.toml": "\n".join(
                    [
                        "token_uri = 'https://oauth2.googleapis.com/token'",
                        "DATABASE_URL=mysql://host:port/db",
                        'trusted_hash = "sha256:' + "a" * 64 + '"',
                        "NODE_REPL_TRUSTED_BROWSER_CLIENT_SHA256S = \"" + "b" * 64 + '"',
                    ]
                )
            }
        )

        self.assertEqual(result.returncode, 0, result.stderr)

    def test_still_blocks_bare_long_hex_without_digest_context(self) -> None:
        # The digest exemption is context-scoped: a naked 64-char hex blob with no
        # sha256/checksum/digest wording on its line must still fail.
        result = self.run_scan({"leak.txt": "value = \"" + "c" * 64 + '"\n'})

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("long_hex_secret", result.stderr)

    def test_still_blocks_real_looking_api_key(self) -> None:
        result = self.run_scan(
            {"env": "ANTHROPIC" + "_API_KEY=sk-ant-" + "x" * 40 + "\n"}
        )

        self.assertNotEqual(result.returncode, 0)

    def test_blocks_database_urls_with_embedded_credentials(self) -> None:
        key = "DATABASE" + "_URL"
        url = "postgres://user:" + "password" + "@db.example.com/app"
        result = self.run_scan({"env.example": f"{key}={url}\n"})

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("database_url_with_credentials", result.stderr)

    def test_blocks_npm_auth_tokens(self) -> None:
        line = "//registry.npmjs.org/:_auth" + "Token=" + "npm_" + ("a" * 36)
        result = self.run_scan({".npmrc": line + "\n"})

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("npm_auth_token", result.stderr)

    def test_blocks_cookie_headers(self) -> None:
        header = "Cookie: session=" + ("a" * 32)
        result = self.run_scan({"headers.txt": header + "\n"})

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("cookie_header", result.stderr)

    def test_blocks_signed_urls(self) -> None:
        url = "https://example.com/file?X-Amz-Signature=" + ("a" * 64)
        result = self.run_scan({"links.txt": url + "\n"})

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("signed_url_signature", result.stderr)


if __name__ == "__main__":
    unittest.main()
