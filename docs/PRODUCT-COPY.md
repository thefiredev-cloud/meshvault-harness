# Product copy (for thefiredev.com and meshvault.ai)

Use as written or tighten. Every claim below is true of the shipped installer.

## Headline

**Your own private AI agent, installed on your computer.**

## Subhead

One command sets up an AI agent, a coding agent and a local model on hardware you own. Nothing you type leaves the machine unless you choose a cloud model. Free and open source. Want it done for you? Book an install.

## Three facts

* **One command.** Linux or Mac. No account, no API key.
* **Private by default.** The model runs on your machine and listens only on 127.0.0.1. Skills stop and ask before they send, pay, post or delete.
* **Honest about limits.** Local models are not frontier models. On a laptop CPU the first reply can take minutes. Apple Silicon and GPUs are fast. 16 GB of RAM is the sensible minimum.

## Install block (copy exactly)

```bash
curl -fsSL https://raw.githubusercontent.com/thefiredev-cloud/meshvault-harness/main/install.sh | bash
```

## Tiers

| Free core | Pro skills pack, $99 | Done-for-you install, $499 |
|---|---|---|
| The installer, the `meshvault` command, 11 skills. MIT. | 9 more skills, memory templates, runbooks, routing recipes, 12 months of updates. | We set it up on your machine over a screen-share and build your first workflow. One machine, 30 days of email support. |
| GitHub | Email contact@meshvault.ai | Book a 20-minute call |

## Done-for-you install: what is included

* A 20-minute call to check your machine and goals.
* A screen-share session (up to 90 minutes) where we install and test the harness on one computer you own.
* The right model for your hardware, Hermes and OMP configured, free skills and the Pro pack installed.
* One real workflow built with you (for example inbox triage drafts or a weekly report).
* A one-page "how to use it" note and 30 days of email support.

Not included: a second machine, custom integrations, hosting, cloud API costs, or any guarantee that a small local model matches a cloud model on hard tasks.

## FAQ

**Is it really free?** Yes. The installer, CLI and 11 skills are MIT licensed.
**Does it send my data anywhere?** The harness itself adds no telemetry. Hermes and OMP are separate open-source tools; if you add a cloud model or a messaging app, that traffic goes where you point it.
**What hardware do I need?** 8 GB RAM minimum, 16 GB recommended, 15 GB free disk. Apple Silicon Macs run it best. A GPU helps on Linux.
**Can it run my business for me?** It drafts and prepares. Anything that sends, pays, posts or deletes waits for your approval.

Links: repo https://github.com/thefiredev-cloud/meshvault-harness  ·  docs https://github.com/thefiredev-cloud/meshvault-harness#readme
