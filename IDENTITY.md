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
| ACTOR | Your shorthand in this repository | `G`, `X`, `DD`, `Q`, `AA`, `HHC`, `MBC`, or your agent name |
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

## Known actor purposes

These are durable **responsibilities**, not proof that a named session is
running, connected or authorized. A project's current Issue/Spec and actual
session binding decide who can act.

| Alias | Agent | Owning repository / area | Purpose | Authority boundary |
| --- | --- | --- | --- | --- |
| **G** | ChatGPT | Portfolio coordination; Agent OS (`amitkarpe/agents`) | Synthesize intent, coordinate/review, curate reusable knowledge | No implicit code, merge, cloud or host authority; follow each owning project's approval |
| **X** | Codex when assigned as coding worker | The **current task's** repository | Implement, test and report bounded work | Only the authorized Issue/Spec/instruction and current repository rules; not every Codex session |
| **DD** ("Didi" / `dd`) | Codex | `amitkarpe/dotfiles` (owner-managed) | Maintain OS files, developer setup, configuration/settings, installers, backup and recovery | Host/config/secret mutations require dotfiles authority and safeguards; identity alone grants none |

`HHC` (Home Claude) and `MBC` (MacBook Claude) are observed Claude Code
**session labels**, not permanent portfolio roles or fixed repository owners.
For them and any `Q`, `AA` or new alias, use the actual current task's
identity header; do not invent a lasting purpose, host or authority.

Keep this table small. Add an enduring alias only after the owner confirms its
purpose and owning area. Store live thread IDs, host paths, availability and
permission details in the **private owning runtime**, never here.

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
