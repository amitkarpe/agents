---
type: Policy
title: Connector Safety Gate
description: Keep connector failures distinct from authority and retry only within unchanged bounds.
status: reviewed
confidence: high
scope: Reusable public-safe agent guidance
review_after: 2027-04-23
tags: [connector, safety, recovery]
---

# Connector Safety Gate

A connector or platform safety block is **not automatically** stale state, invalid credentials, insufficient permissions, failed validation or an owner approval request. Classify those separately. Connector access does not create authority: current repository approval and safety boundaries still control.

For a **previously authorized** bounded action blocked by connector safety:

1. Re-read exact repository/service, target, branch, SHA and current action scope.
2. Retry the **identical action at most once** without altering safeguards, permission, model/effort, identity or target to evade the restriction.
3. If blocked again, stop and report `BLOCKED_CONNECTOR_SAFETY`.
4. Use an existing authorized local/repository worker route only when it preserves the exact scope and no-go conditions; otherwise stop. Log that handoff in the owning Issue/PR.

A stale branch SHA, auth error or supported-product limitation has its own recovery procedure. Do not create a duplicate writer or assume a queued handoff means execution. Correlate the result and read back the changed state.

## Related

- [Shared instructions](AGENTS.md)
- [Goals](GOALS.md)
- [ChatGPT/Codex collaboration](chatgpt/COLLABORATION.md)

## Citations

- [repo-starter connector safety guidance](https://github.com/amitkarpe/repo-starter/blob/main/CHATGPT.md#connector-safety-gate)
