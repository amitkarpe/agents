---
type: Policy
title: Context Loading and Handoffs
description: Load authority on change and reuse known warm context without losing safety.
status: reviewed
confidence: high
scope: Reusable public-safe agent guidance
review_after: 2027-04-23
tags: [context, handoff, authority]
---

# Context Loading and Handoffs

**Load on change, not on every turn.** A directory, pointer or provider adapter is not proof that a rule was actually loaded. Agent OS provides reusable knowledge, not new authority over the active repository, Issue/PR or approved goal.

## Cold start

Establish the actual repository/worktree identity, current HEAD, owning Issue/PR and its governing `AGENTS.md`. Read `CONTEXT.md`, `SPEC.md`, `ROADMAP.md`, host settings and broader history only when a concrete task, governing reference or changed fingerprint requires them. Honor repository-specific mandatory startup rules.

## Warm continuation

Read the latest **authorized** delta, current status/diff and exact files for the next action. Reuse valid loaded rules and fingerprints. A new turn, comment, PR, session or milestone is not itself a reason to reread everything; nor is the newest comment necessarily an approval.

Reload affected context if repository, Goal, provider, execution host or authority is unclear; a governing file materially changes; state is missing, stale or contradictory; or the work enters a new security, production, destructive or trust boundary. Never infer missing authority.

## Handoffs and task-scoped use

A compact handoff carries approved outcome, scope, stop gates, current Issue/PR, relevant authorized comment, verified worker identity, current HEAD and acceptance evidence. A queue receipt is not execution. Preserve actual host restrictions even when browser/chat and executor are on different machines; remote compute does not permit moving restricted data.

Select **one to three** relevant topics from the [README index](README.md), not the entire corpus. For a real project: **learn** one matching canonical topic, **apply** it under repository authority, then **contribute** only a sanitized, genuinely reusable learning candidate. Keep local runtime facts in their existing dotfiles/native/private owner, never public Agent OS.

Before retiring older files, inventory active consumers, preserve unique content and establish rollback. A paper policy or link is not a native automatic-loading proof.

## Related

- [Core authority](AGENTS.md)
- [Goals and delegation](GOALS.md)
- [Connector safety](SAFETY.md)
- [ChatGPT/Codex collaboration](chatgpt/COLLABORATION.md)
