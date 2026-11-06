---
type: Policy
title: Agent Identity Header
description: One identity header for every agent-written Issue, PR, handoff and cross-repository question, so a reader knows who writes and where it runs.
status: candidate
scope: All repositories where agents write Issues, comments or PRs
confidence: medium
timestamp: 2026-11-06T14:00:00+08:00
review_after: 2027-05-06
tags: [identity, collaboration, issues, pull-requests, handoff]
---

# Agent identity

Many agents work with Amit at the same time. A reader must know **who** writes, **where** it runs and **why**, without guessing. This file is the single canonical format. `chatgpt/COLLABORATION.md` points here.

## When to use which header

| Text | Header |
|---|---|
| New Issue, new PR, handoff, environment change, question in another repository | **Full** header (below) |
| Routine reply or status line in a thread you already joined | **Short** header |

Short header: `<HHC · Claude Code · OWNER/REPO>` (actor, agent, repository you work for).

## Full header

```text
<Identity: ACTOR | Agent: AGENT | Surface: SURFACE | Host: HOST | Execution: EXEC | Repo: OWNER/REPO | Role: ROLE>
Evidence: <link to the Issue, PR, run or log; omit when there is none>
```

| Field | Meaning | Values |
|---|---|---|
| ACTOR | Your shorthand in this repository | `G`, `X`, `Q`, `AA`, `HHC`, `MBC`, or your agent name |
| AGENT | Provider and product that writes the text | `Claude Code`, `Codex`, `ChatGPT`, `Kiro` |
| SURFACE | The product surface | `CLI`, `web`, `desktop`, `cloud task` |
| HOST | The kind of machine | `Mac`, `Windows`, `Linux`, `cloud`, `unknown` |
| EXEC | Where the work runs, seen from the owner | `local` (the owner's own machine), `remote` (a machine reached by SSH or Remote Control), `cloud` (a vendor-hosted task), `unknown` |
| Repo | The repository you work **for** (not the one that receives the text) | `OWNER/REPO` |
| ROLE | What you do now | `implementer`, `reviewer`, `controller`, `requester` |

Examples:

```text
<Identity: HHC | Agent: Claude Code | Surface: CLI | Host: Linux | Execution: local | Repo: amitkarpe/aws-factory | Role: requester>
<Identity: G | Agent: ChatGPT | Surface: web | Host: cloud | Execution: cloud | Repo: amitkarpe/agents | Role: reviewer>
```

An older header with the first four fields stays valid. Add `Surface`, `Host` and `Execution` when you can state them as facts.

## Ask in another repository

Right after the full header, write four lines:

1. **From:** the repository and Issue you work for.
2. **Why:** the reason in one sentence.
3. **Need:** one exact answer or action.
4. **Evidence:** a link.

## Never

- Do not guess the environment, the model or the host. Write `unknown`.
- Do not write secrets, session IDs, machine names, user names or IP addresses.
- Do not use the identity of another agent. A reply uses the responder's own identity.
- Identity is attribution, not approval. It does not grant any permission.

## Adopt it

- New repository: `repo-starter` `INIT.md` points here. Do not copy this file into each repository.
- Existing repository: one PR adds this line to its `AGENTS.md`: "Follow `amitkarpe/agents` `IDENTITY.md` in new Issues, PRs, handoffs and cross-repository questions." Check with `grep -q IDENTITY.md AGENTS.md || echo "not adopted"`. The owner's agent of that repository makes the PR once.
- Every agent that loads the canonical policy from `~/.agents` finds this file in the `README.md` table.
- Do not add a framework, a registry or a workflow for this.
