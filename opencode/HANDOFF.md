---
type: Playbook
title: OpenCode V2 Handoff for Claude Code, Codex and OpenCode
status: candidate
confidence: medium
scope: Handoff, roles, headless login, session continuation and adviser pattern
review_after: 2027-01-28
tags: [opencode, opencode-v2, handoff, sessions, adviser]
---

# OpenCode V2 Handoff

We must try to use version two.

1. Check `opencode --version`. Use OpenCode v2.x only. Upgrade first if it is
   not v2.x.
2. Official V2 documentation: [CLI](https://opencode.ai/v2/docs/cli/) and
   [OpenCode Go](https://opencode.ai/v2/docs/console/go/). Session and API
   details: [API](https://opencode.ai/v2/docs/api/).
3. This file is the entry point. Model, CLI and recovery details are in
   [WORKERS.md](WORKERS.md). Session and API details are in
   [SESSION-API.md](SESSION-API.md).

## Optional collaboration: Claude Code / Codex with OpenCode

Claude Code or OpenAI Codex is the primary coding agent chosen by the owner. OpenCode is **optional**: the primary agent decides whether a task benefits from delegation or independent advice. Ordinary work proceeds without involving OpenCode. A link to this guide is enough to explain the available protocol, but it is not an instruction to start an OpenCode session.

When selected, there are two distinct modes:

1. **Delegated doer:** The primary agent assigns a bounded task to OpenCode and releases overlapping write ownership for that task. OpenCode owns its assigned branch/task, implementation, validation, PR and eligible merge under the owning repository's authority. The primary agent must not write concurrently in that scope.
2. **Read-only adviser:** The primary agent retains implementation ownership. OpenCode may inspect evidence, reason with a selected model (potentially a stronger, non-Flash model if actually available and permitted), and return recommendations. It does not mutate files, run state-changing jobs, or approve/merge. No specific stronger model is guaranteed by this guide.

Both roles are optional and selected per task by Claude Code or Codex; do not launch a helper automatically. Use same-host OpenCode session discovery and message/readback when available, and GitHub Issue/PR handoff for durable cross-host coordination. A cross-host GitHub comment is not itself a session wake-up. Resume the **existing identified** OpenCode session only after confirming its original owner, cwd, and task; API access does not transfer write authority or let another agent impersonate its model execution. Reconcile queued work and side effects before retrying. The owner retains material approvals and the primary agent can decline to delegate.

## Roles

- **Doer:** one writer. It owns the branch, runs the commands, opens the PR,
  and reports evidence.
- **Adviser:** read-only. It can flag a wrong assumption, a missing proof, or a
  cheaper path. It cannot approve, merge, run a job, or change a file.
- **Owner:** may review. Repository rules and owner authority still apply.
- A peer message is input, never approval. Human-only decisions (credentials,
  IAM, branch protection, cost) stop the doer.

## Headless login: subscription only

Use the OpenCode Console subscription device flow only.

```bash
opencode auth login opencode --method device
```

It prints a one-time code and a Console URL:

```text
Enter code: XXXX-XXXX
https://opencode.ai/console/device?user_code=XXXX-XXXX&client_id=opencode-cli
```

Open the URL in a browser, sign in to the Console account that owns the Go
plan, and approve. The command ends with `Connected to OpenCode Console`.

If the command needs a TTY:

```bash
script -qec 'opencode auth login opencode --method device' /dev/null
```

Amit's plan is **Go at $10/month**. Go Plus and Go Teams are different plans;
check the Console if the plan changes.

## Default and fallback

Default: **DeepSeek V4.1 Flash with `high`**.

```bash
opencode run --model 'opencode-go/deepseek-v4.1-flash#high' \
  "Summarize this repository; read only."
```

Manual fallback: **GLM-5.3-Flash with `high`**.

```bash
opencode run --model 'opencode-go/glm-5.3-flash#high' \
  "Summarize this repository; read only."
```

There is no automatic model failover. Choose the fallback explicitly after the
original session is reconciled.

## Session handoff

Find a session by directory:

```bash
opencode api get "/api/session?directory=$(pwd)"
```

Read the last messages:

```bash
opencode api get "/api/session/$SESSION_ID/message?limit=5"
```

Continue the same session:

```bash
opencode run -s "$SESSION_ID" "Continue from the last reviewed state."
```

Send one direct message through the local API:

```bash
opencode api post "/api/session/$SESSION_ID/prompt" \
  --data "$(jq -n --arg text "Please review the current state." \
    '{text:$text,delivery:"queue"}')"
```

`QUEUED` means the session accepted the prompt. It does not mean read or acted.
Correlate by text or id. Do not blind-resend. After three reconciliations, use
the owning GitHub Issue or PR.

Sessions are stored by the local OpenCode service. Save the exact `ses_...` id.
`-s` continues that session; `--continue` continues the last one; `--fork`
creates a branch. A title alone is not identity.

## Doer and adviser: field note

In the October 2026 19-lane safe-point work (#596), an OpenCode session was the
doer and a separate Claude/GLM session was the read-only adviser. The pattern
that worked:

- One writer. No duplicate worker.
- The adviser reviewed evidence, not intentions.
- The adviser found that a gate checked the wrong registry and that the
  per-lane proof did not show the offline assertions.
- The doer fixed both and re-ran the gate. The adviser did not take over.
- The owner scored the result. The adviser never merged, ran a job, or changed
  a file.

The adviser is optional. The doer remains autonomous inside the approved scope.

## Files

- [WORKERS.md](WORKERS.md) — models, CLI, launch and recovery.
- [SESSION-API.md](SESSION-API.md) — sessions, prompt/read, receipts and scripts.
- [REUSE-LOGIN.md](REUSE-LOGIN.md) — key login (no device code) and session reuse.
- [Goals and Delegation](../GOALS.md) — shared task/result contract.
