---
type: Policy
title: Claude Session Messaging Protocol
description: How Claude Code sessions (local, cloud, other machines) talk to each other and to Codex/OpenCode without the owner relaying messages.
status: candidate
scope: All repositories where more than one Claude Code session works
confidence: medium
timestamp: 2026-11-08T00:00:00+08:00
review_after: 2027-02-08
tags: [claude-code, sessions, messaging, handoff, coordination]
---

# Claude session messaging protocol

Goal: the owner talks to **one** coordinator. Other sessions get work and answer without the owner relaying text.
A message is a **pointer**. The durable record is the owning Issue or PR. Identity header: see [IDENTITY.md](IDENTITY.md).

## What the platform does (verified against the Claude Code docs, Nov 2026)

- `ListAgents` + `SendMessage` reach other Claude Code sessions **on the same machine** over a local socket. Docs: [cross-session messaging](https://code.claude.com/docs/en/cross-session-messaging.md).
- **Delivered is not read, and read is not done.** The tool reports delivery only. A reply happens only if the receiving Claude sends one.
- `SendMessage` with `notify_when_idle: true` is documented for local sessions (v2.1.236+), but **Claude Desktop refused it** on 8 Nov 2026 ("only supported for Claude sessions on this machine in this release"). For Desktop sessions do not rely on it: use the `DONE` message, or the app's note when a session you started ends its turn.
- Permission modes decide delivery. A receiver that prompts for permissions delivers, unless the sender runs in bypass mode, then it **holds** the message. A receiver in bypass mode holds unless the sender also bypasses. The Desktop app cannot show the approval dialog, so a held message expires (default 5 minutes, `dialogExpiry`). Set `crossSessionInbound` to `accept` only for sessions the owner trusts.
- **Cloud sessions and other machines** are visible only while the sender is connected to Remote Control (claude.ai login, no API key). A cloud session **cannot answer** with `SendMessage`; its answer is in its transcript at claude.ai/code.
- A peer message never counts as owner approval, never changes settings, and slash commands in it do not run.

## Routing: pick the channel by target

| Target | Channel | Reply is read from | Wake-up and risk |
|---|---|---|---|
| Session started by you (worker) | `start_session`, brief with done-criteria | The app note when its turn ends | Parent sees the note; none if the app is closed |
| Other local session | `@name` or `SendMessage` with the envelope below | `DONE` message or Issue comment | Not listed means closed: open it in the app. Address by name; IDs change on restart |
| Cloud session | `SendMessage` (needs Remote Control), or a headed Issue comment | Its transcript or an Issue comment | Cannot reply by message. May act on a peer message only after owner approval, or when a standing approval (rule 7) covers the ask |
| Project coordinator (cloud project chat) | Message a Remote Control bridge session on the Mac and ask it to reply in its thread | The project chat (not GitHub) | Woken by a thread reply (reported by the coordinator, observed once on 8 Nov 2026). The bridge parks when the Mac sleeps: keep it awake or expect a delay |
| Session on another machine | Remote Control message if listed and not `offline` | Its transcript or an Issue comment | `offline` until that machine reconnects |
| Codex / OpenCode | Issue comment with identity header; same-host session API only per `codex/SESSIONS.md`, `opencode/HANDOFF.md` | Issue/PR evidence | A comment is not a wake-up |

Do not build standing watchers or daemons to support this; bounded polling inside one turn (rule 8) is fine. Do not resume another agent's session; two writers corrupt it.

## Message format

```text
<Identity: ACTOR | Agent: Claude Code | Surface: desktop | Host: Mac | Execution: local | Repo: OWNER/REPO | Role: controller>
ID: <short unique id, e.g. 1108-01>
ASK: <one action or one question>
DONE-WHEN: <the evidence that closes it: run, job, PR or comment link>
REPLY-TO: <session name, or Issue/PR link when the receiver cannot message back>
```

Receiver: send `ACK <ID>` in the same turn, then `DONE <ID> <evidence link>` when finished. A refusal is `REFUSED <ID> <reason>`.

## Rules

1. One writer per branch or file set. The coordinator assigns, workers do not self-assign.
2. No ACK is not a failure. Check the idle notice, the transcript or the Issue before resending. Never send the same ASK twice.
3. "Done" means the `DONE-WHEN` evidence exists, not that the message was delivered or the session went idle.
4. Every handoff to a session that cannot message back records on the Issue: expected time, readback command, who acts, and what happens if nobody wakes.
5. Messages carry no secrets, tokens, session IDs, machine or user names. Live session names and IDs go in the **private** owning runtime repository, never here.
6. Identity is attribution, not approval. Human-only decisions (credentials, IAM, production, destructive, cost) stop the work and go to the owner once.
7. **Standing approval, once per Issue.** The owner records one block on the owning Issue naming what relayed asks may do (status, ACK/DONE, read-only checks, comments on that Issue). A relayed ask cites it. A peer message never creates approval; it only points at the owner's recorded one. Production, credentials, destructive and cost actions are never covered; it does not widen rule 6.
8. **The receiver posts its own reply** on the Issue named in the ask. Nobody copies replies between sessions. The sender reads the Issue in bounded checks (about 10 seconds apart, a few times), then stops and records "no reply yet".
9. **A worker keeps a long wait inside one turn.** Every turn end wakes the session that started the worker. For a long run (a lab test, a measurement), start it in the background and wait with a bounded foreground loop (a few minutes per call, a fixed upper limit), instead of ending the turn at each step. Report on a failure or at the end; routine progress goes to the run log.

## Cross-provider status (8 Nov 2026, same host unless noted)

| Path | Status |
|---|---|
| Claude session <-> Claude session | Verified two-way |
| Claude <-> Codex | Verified in both directions (native inbox, reply read from the transcript) |
| Codex <-> ChatGPT | Verified through a dedicated tunnel and MCP, reply readable by ChatGPT |
| ChatGPT -> interactive Claude session | No record; AO headless dispatch covers bounded turns only |

Re-read this table in the next quarter or at the next Claude Code major release.

## Test matrix (record results on the tracking Issue; 8 Nov 2026: tests 1-2 run; cloud and coordinator ACK tests C1, C4, C5 passed; see agents#100)

1. Local ACK: coordinator -> idle local session, expect `ACK` and `DONE`.
2. `notify_when_idle`: tested 8 Nov 2026 in Claude Desktop: refused. Retest on a CLI session.
3. Held message: sender in bypass mode, receiver prompting; record whether it is held or delivered.
4. Cloud wake: Issue comment, then check whether a cloud routine on the GitHub event starts the cloud session. Record the delay.
5. Failure case: message to a session set to `refuse`; expect `Not sent` or silent drop, and record which.

## Citations

- [Message your other Claude Code sessions](https://code.claude.com/docs/en/cross-session-messaging.md)
- [Orchestrate teams of Claude Code sessions](https://code.claude.com/docs/en/agent-teams.md)
- [Remote Control](https://code.claude.com/docs/en/remote-control.md)
- [Channels](https://code.claude.com/docs/en/channels.md)
