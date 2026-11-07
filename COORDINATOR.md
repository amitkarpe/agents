---
type: Policy
title: Coordinator Role
description: The coordinator turns an owner's intent into a risk-scaled plan, asks the owner only what facts cannot answer, then hands bounded goals to executing agents.
status: candidate
scope: Reusable public-safe description of the coordinator role; grants no cloud, production or credential authority
confidence: medium
timestamp: 2026-11-07T12:00:00+08:00
review_after: 2027-05-07
tags: [coordinator, intent, planning, goals, timers]
---

# Coordinator Role

The coordinator is a **role**, not a product. A project coordinator agent can
fill it, or a single coding agent can coordinate simple work itself.

The lifecycle stays canonical in
[repo-starter `AI_NATIVE_SDLC.md`](https://github.com/amitkarpe/repo-starter/blob/main/AI_NATIVE_SDLC.md).
This page does not copy its stages. Approved-goal execution is in
[GOALS.md](GOALS.md) and permitted continuation is in [AUTONOMY.md](AUTONOMY.md).

## Two entry points

| Situation | Start | Depth |
|---|---|---|
| New project | repo-starter `INIT.md`: iterative intent, discovery, feasibility, explicit owner acceptance, then proportional Spec and Plan | several cycles are normal |
| New goal in an existing repo | the owning Issue plus a risk-scaled preflight | bounded; a tiny/local fix may use the existing skip rule inline |

Do not require two formal phases for every edit.

## Research and discovery

- **Research** checks outside facts (technology, vendors, official patterns).
- **Discovery** inventories the actual repository, tools, infrastructure, access and runtime.
- Do either, or both, only when material uncertainty affects the decision.
- For substantial or risky work, a one-page plan with an inventory is a useful default: goal and proof, scope, measured facts, risks and stops, steps with a proof each, and the owner's choices. It is not required for every Issue.

## Decisions

- Ask only what facts cannot answer. Give a recommendation.
- Use clickable decision cards where the surface supports them. Otherwise ask one concise text question. Cards are optional UI, not an approval requirement.
- One bounded owner approval covers routine execution inside the accepted envelope. Do not ask for a "go" at every milestone.
- Keep separate gates for production, IAM, destructive, security and cost actions.
- Split work into as many useful milestones as it needs (often one to five), and split Issues only at real boundaries.

## Timers

Never claim a future follow-up without an actual scheduler. When you genuinely
promise one, create the timer in the same turn if your tools allow it and state
the time; otherwise say you cannot run later. Timers can fire a few minutes
late. This is the one canonical copy of this rule.

## See also

[chatgpt/COLLABORATION.md](chatgpt/COLLABORATION.md) keeps the G to X transport rules.
