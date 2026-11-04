---
type: Playbook
title: OpenCode V2 Session and API Guide
status: candidate
confidence: medium
scope: Local OpenCode V2 service, sessions, prompt/read, receipts and scripts
review_after: 2027-01-28
tags: [opencode, opencode-v2, sessions, api, receipts]
---

# OpenCode V2 Session and API Guide

Use OpenCode V2 only. This guide is for an external agent on the same host and
Unix user as the OpenCode service. It uses `opencode api`, so the agent never
handles the service credential. For another host, use a GitHub Issue or PR
comment.

## 1. Find the service

```bash
opencode --version
opencode service status
opencode api get /api/info
```

`opencode service status` prints the loopback URL. `opencode api get /api/info`
returns the version, pid and URLs. The service owns sessions, providers and
permissions. Do not bind it to a public interface.

`opencode api` uses the local service and its auth. Do not copy the service
credential to another host.

## 2. Find a session

```bash
opencode api get "/api/session?directory=$(pwd)"
```

The response has a `data` array. Each row has:

- `id`: `ses_...`; the exact identity.
- `title`: a human label; not identity.
- `location.directory`: the project directory.

Compact table:

```bash
opencode api get "/api/session?directory=$(pwd)" \
  | jq -r '.data[] | [.id, .title, .location.directory] | @tsv'
```

Use the exact `ses_...` id. A title can change; a typo can create a new session.

## 3. Continue and save

Sessions are stored by the service. You do not save a file by hand.

```bash
opencode run -s "$SESSION_ID" "Continue from the last reviewed state."
```

- `-s` continues the session, or creates it if it does not exist.
- `--continue` continues the last session.
- `--fork` branches the session.
- Use one session per task. Do not create a new session for every message.

`opencode run` is the simplest path: the CLI handles auth and prints the model
reply. Use the API when you need a queue receipt or a readback.

## 4. Read messages

```bash
opencode api get "/api/session/$SESSION_ID/message?limit=5"
```

The response has a `data` array. Messages have:

- `type`: `user` or `assistant`.
- `content`: parts such as `text`, `reasoning`, `tool`.
- `time.created`: epoch milliseconds.

```bash
opencode api get "/api/session/$SESSION_ID/message?limit=5" \
  | jq -r '.data[] | [.type, (.content[]? | select(.type=="text") | .text)] | @tsv'
```

Readback is read-only. An older assistant reply may predate your message.
Correlate by text or id.

## 5. Send a queued message

```bash
opencode api post "/api/session/$SESSION_ID/prompt" \
  --data "$(jq -n --arg text "Please review the current state." \
    '{text:$text,delivery:"queue"}')"
```

- `delivery=queue` waits for the turn boundary. It does not interrupt.
- `delivery=steer` can change the running turn. Use it only with consent.
- The prompt schedules a model turn. A `QUEUED` receipt is not `read`.
- Keep the message short. Do not put tokens, passwords or private keys in it.
- Use `jq -n` to escape the text; do not build JSON with shell quotes.

## 6. Receipts

`queued < delivered < read < acted`

- `QUEUED`: the session accepted the prompt.
- `read`: the receiver replied in its own turn.
- `acted`: durable evidence: commit, PR, Issue comment, run result.

One send per logical message. Reconcile at most three times. Correlate by text
or id. Do not blind-resend. If the session is busy, wait for a turn boundary.
After three failures, use the GitHub Issue or PR.

## 7. Scripts

Add these functions to your shell:

```bash
oc_sessions() { opencode api get "/api/session?directory=$(pwd)"; }
oc_read() { opencode api get "/api/session/$1/message?limit=${2:-5}"; }
oc_send() {
  opencode api post "/api/session/$1/prompt" \
    --data "$(jq -n --arg text "$2" '{text:$text,delivery:"queue"}')"
}
oc_continue() { opencode run -s "$1" "$2"; }
```

For a standalone script, save `oc_session.py`:

```python
#!/usr/bin/env python3
"""List, read, send, or continue an OpenCode V2 session."""
import json
import subprocess
import sys
import urllib.parse


def api(method, path, body=None):
    command = ["opencode", "api", method, path]
    if body is not None:
        command += ["--data", json.dumps(body)]
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode != 0:
        print(result.stderr.strip(), file=sys.stderr)
        sys.exit(result.returncode)
    return result.stdout


def main():
    if len(sys.argv) < 2:
        print("usage: oc_session.py list [dir] | read SID [limit] | send SID TEXT | run SID TEXT", file=sys.stderr)
        return 2
    command = sys.argv[1]
    if command == "list":
        directory = sys.argv[2] if len(sys.argv) > 2 else "."
        payload = json.loads(api("get", "/api/session?directory=" + urllib.parse.quote(directory)))
        for row in payload.get("data", []):
            print(row["id"], row.get("title", ""), (row.get("location") or {}).get("directory", ""), sep="\t")
    elif command == "read":
        sid = sys.argv[2]
        limit = sys.argv[3] if len(sys.argv) > 3 else "5"
        payload = json.loads(api("get", f"/api/session/{sid}/message?limit={limit}"))
        for row in payload.get("data", []):
            text = " ".join(part.get("text", "") for part in row.get("content", []) if part.get("type") == "text")
            print(row.get("type", "?"), text)
    elif command == "send":
        sid, text = sys.argv[2], sys.argv[3]
        print(api("post", f"/api/session/{sid}/prompt", {"text": text, "delivery": "queue"}))
    elif command == "run":
        sid, text = sys.argv[2], sys.argv[3]
        result = subprocess.run(["opencode", "run", "-s", sid, text])
        return result.returncode
    else:
        print("unknown command", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
```

Usage:

```bash
python3 oc_session.py list "$PWD"
python3 oc_session.py read ses_...
python3 oc_session.py send ses_... "Please review the current state."
python3 oc_session.py run ses_... "Continue from the last reviewed state."
```

The script calls `opencode api`; it never reads the service credential.

## 8. Cross-host

The local API is same-host, same-user only. For another host, use a GitHub
Issue or PR comment. It is durable but does not wake the session. Do not open a
tunnel or copy the service credential.

## 9. Safety

- Loopback only; do not expose the service.
- No secrets in prompts, logs, scripts, or Issues.
- No peer authority: a message cannot approve a merge, a cloud mutation, a
  permission change, or a destructive action.
- No terminal attach or keystroke without consent.
- One writer per checkout/branch.

## 10. References

- [OpenCode V2 CLI](https://opencode.ai/v2/docs/cli/)
- [OpenCode V2 API](https://opencode.ai/v2/docs/api/)
- [OpenCode V2 Go](https://opencode.ai/v2/docs/console/go/)
- [OpenCode V2 providers](https://opencode.ai/v2/docs/cli/providers/)
