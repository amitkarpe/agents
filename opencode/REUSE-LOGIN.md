---
type: Playbook
title: Reuse OpenCode login and sessions with OPENCODE_TOKEN
status: candidate
confidence: medium
scope: Key-based OpenCode login for cloud sessions/VMs, no device code; session reuse
review_after: 2027-02-14
tags: [opencode, opencode-v2, login, token, sessions, cloud]
---

# Reuse OpenCode login and sessions

Goal: a new cloud session or VM runs OpenCode **without web login and without
device-code copy-paste**, and continues earlier sessions instead of starting
from zero. Entry point stays [HANDOFF.md](HANDOFF.md).

## 1. Where the key lives

| Place | Who reads it | How it is set |
|---|---|---|
| `~/.env` on the VM, line `OPENCODE_TOKEN=...` | shell / scripts | once, by the owner, `chmod 600 ~/.env` |
| Cloud environment variable `OPENCODE_TOKEN` | every new cloud session | environment settings, `NAME=value`, no `export` |
| Repo secret `OPENCODE_TOKEN` | GitHub Actions only | repo settings → Secrets |

The key is the OpenCode Console (Go plan) API key. Only the owner creates or
rotates it, in the Console.

## 2. Load the key without printing it

```bash
# load ~/.env silently; never `cat`, `echo` or `env | grep` the value
set -a; . ~/.env; set +a
: "${OPENCODE_TOKEN:?OPENCODE_TOKEN missing}"   # fails loudly, prints no value
export OPENCODE_API_KEY="$OPENCODE_TOKEN"        # name OpenCode reads for its own provider
```

Optional: store it once in OpenCode's auth file, so every later shell works
without step 2 (the file stays local, mode 600):

```bash
umask 077; d=~/.local/share/opencode; mkdir -p "$d"
jq -n --arg k "$OPENCODE_TOKEN" '{opencode:{type:"api",key:$k}}' > "$d/auth.json.new"
[ -f "$d/auth.json" ] && jq -s '.[0]*.[1]' "$d/auth.json" "$d/auth.json.new" > "$d/auth.json.tmp" \
  && mv "$d/auth.json.tmp" "$d/auth.json" || mv "$d/auth.json.new" "$d/auth.json"
rm -f "$d/auth.json.new"
opencode auth list        # shows provider names only, not the key
```

Auto-load for each new shell (add once to `~/.bashrc`):

```bash
[ -f ~/.env ] && { set -a; . ~/.env; set +a; export OPENCODE_API_KEY="${OPENCODE_TOKEN:-}"; }
```

## 3. Check the login works

```bash
opencode --version                      # must be 2.x
opencode run --model 'opencode-go/deepseek-v4.1-flash#high' "Reply with OK only."
```

- `[overloaded]` → wait 20 s, run once more. No loop of blind retries.
- `401` / auth error → key missing, wrong or rotated. Ask the owner; do not
  fall back to the device flow silently.
- Fallback model: `opencode-go/glm-5.3-flash#high`.

## 4. Login options compared

| Method | Web / device code each session? | Works headless | Use when |
|---|---|---|---|
| Key in env (`OPENCODE_API_KEY`) | ❌ No | ✅ | default for cloud sessions, CI, scripts |
| Key in `auth.json` | ❌ No (once per VM) | ✅ | long-lived VM |
| Device flow (HANDOFF.md) | ✅ Yes | ⚠️ needs a human | no key available |

## 5. Reuse sessions and context

Sessions live in OpenCode's local store (`~/.local/share/opencode`) on that
machine. Reuse the **same VM** and they stay; a fresh container starts empty.

```bash
cd /path/to/repo                                   # sessions are per directory
opencode session list                              # find the ses_... id
opencode run -s "$SESSION_ID" "Continue from the last reviewed state."
opencode run --continue "Next step."               # last session in this dir
opencode run -s "$SESSION_ID" --fork "Try plan B." # branch, keep original
```

Save the exact `ses_...` id in the owning Issue/PR, not only a title.
More API detail: [SESSION-API.md](SESSION-API.md).

Move context to another machine (only if needed):

| Option | Secret risk | Note |
|---|---|---|
| Same VM, keep `~/.local/share/opencode` | low | best; do not destroy the VM |
| `opencode export $SESSION_ID > s.json` then `opencode import s.json` | ⚠️ transcript may hold data | copy by `scp`, never commit |
| Summary in the GitHub Issue/PR | none | durable, works across hosts and teams |

## 6. For other teams (e.g. Nextflow offline work)

1. Owner gives the team its own Console key (one key per team; easy to rotate).
2. Team puts it in `~/.env` as `OPENCODE_TOKEN`, runs step 2 and step 3.
3. Team follows HANDOFF.md roles: one doer, optional read-only adviser.
4. Real engagement or sensitive data goes only to approved models.

## 7. Never

- Never print, echo, log, paste or commit the key (`~/.env`, `auth.json`,
  exported sessions stay out of Git).
- Never put the key in a prompt, an Issue, a PR or a chat message.
- Never share one key across machines you do not control; rotate on doubt.
- Never `set -x` while the key is loaded.

## Run on owner's machine / owner only

- Create, rotate or revoke the Console key.
- Set the cloud environment variable and repo secret.
