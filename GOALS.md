---
type: Policy
title: Goal Execution and Delegation
description: Continue one approved agent goal with bounded delegation, evidence, and stop gates.
status: reviewed
scope: Reusable public-safe agent goal execution and delegation
confidence: high
timestamp: 2026-10-21T18:00:00+08:00
review_after: 2027-04-21
tags: [goals, delegation, evidence, agents, context]
---

# Goals and Delegation

The owning project, Issue/PR, specification and approval define authority.
This guide helps an agent execute that work; it does not grant permission for
cloud, production, credentials, publication or destructive actions.

## One approved goal

Use one complete goal for one bounded outcome. It should name the repository,
scope, allowed writes, success evidence and stop conditions. Continue obvious
steps inside that boundary without asking for a new approval at every
milestone. A milestone, plan, push or queue receipt is progress, not proof of
completion.

Start with the smallest current truth: owning Issue/PR, latest handoff,
current HEAD and dirty state. Reload broader context only when the repository,
authority, governing file or safety boundary is unclear or changed. Preserve
unrelated work and stop on conflicting ownership or target identity.

## KISS-FIRST decisions

Choose the smallest useful outcome. Scale investigation to the next action's
concrete risk, especially irreversible, stateful, costly or privileged effects.
Expand scope only for demonstrated exposure, a material unknown affecting that
action, or a governing requirement; a capability or event subscription alone
does not prove execution. An unknown high-impact effect can still hold that action.
Reuse accepted proof and stop when the outcome is demonstrated or a specific
real blocker is established. Before adding a checklist, document, service, test
or review gate, ask whether less work achieves the same result. Existing hard
review, security and owner-approval gates remain binding.

For nontrivial work, briefly state **GOAL | REAL BLOCKER | MINIMUM USEFUL ACTION |
STOP CONDITION** in the existing Issue/PR or plan; do not require a new form for
routine tasks.

Example: in ami-factory-v2 #15, successful GitGuardian checks establish scanner
results, not deployment. Unknown repository-specific trigger effects can hold
the affected push or merge pending targeted evidence or an owner decision;
an App subscription alone neither proves deployment nor justifies auditing
unrelated integrations. This illustration grants no push or merge approval.

## Tight execution loop

For each meaningful wave:

1. ingest current goal and repository truth;
2. choose the next bounded action;
3. implement or execute inside the approved scope;
4. run the narrowest meaningful validation and inspect its output;
5. record durable evidence when the work is long-lived or stateful; and
6. reassess whether the goal is complete or another approved wave remains.

Do not create a watcher, daemon, framework or duplicate runner merely to keep a
goal moving. A long command may be bounded and interruptible, but a process
status or agent display is not completion evidence.

## Delegation

Delegate only an independently answerable question that saves meaningful
coordination or review effort. Give every helper one objective, one owner for
each mutable file set, allowed sources and writes, required evidence, and stop
conditions. Keep one writer per mutable surface; make independent reviewers
read-only. The controller accepts evidence; a worker's report or transport
receipt is not acceptance.

Use the existing provider-native transport and adapter. Transport creates no
authority and does not prove execution. For persistent Codex sessions, use the
[native controller-worker protocol](codex/DELEGATION.md).
Keep provider setup, host paths, versions and authentication in the provider's
local adapter, not in this public guide.

## Stop gates and closeout

Stop and report a blocker when the next action would widen scope, change
authority, touch production or destructive state without approval, expose a
secret/private fact, encounter uncertain identity or ownership, or require a
non-obvious recovery decision. Do not silently create a second worker or
replay an uncertain mutation.

Finish the approved work, validate the actual result, and write the durable
Issue/PR or result record before sending one completion notification. Reconcile
the final repository or external state when the goal changed it. Cleanup is a
separate authorized action: age, TTL, a marker or a queue notice does not grant
deletion authority.
Use [Temporary Agent Evidence Lifecycle](KNOWLEDGE.md)
for retention, preservation and exact-path cleanup checks.

For provider-specific transport use [Codex Delegation](codex/DELEGATION.md),
and for handoff reload rules use [Context](CONTEXT.md).

## Fast or Deep planning — still one approved Goal

**Fast** is the default: record Outcome, Scope, Approved actions, Success proof
and Stop gates; let one existing worker plan and execute the whole outcome.
Milestones are progress markers, **not** routine authorization stops.

Use a **Deep** plan when actual production, destructive, IAM/network/state
mutation, multiple writers/repositories or recovery risks require explicit
phases (normally no more than four), deterministic gates, rollback, exact
environment/account/resource identity and evidence. The plan defines **how**;
the owner-approved Goal defines **what** and **how far**. Do not create Deep
ceremony for straightforward work or demand a new GO for every authorized wave.

## Independent helpers and acceptance

Use subagents for independently answerable, parallel read-heavy work or
meaningful independent review; provide one exact question, allowed sources,
write boundaries, evidence, stop gates and acceptance owner. A single repository
normally has one persistent writer; separate reviewers stay read-only. Human
session names do not prove identity, provider model or execution effort.

## Completion notifications and optional wake logic

The durable **terminal Result** is the source of truth. Verify it, then issue
one small deduplicated pointer if the recipient is available and safe. Check
delivery at most once where required; failure to notify does not erase the
result. Reconcile uncertain dispatch instead of replaying or recreating a
worker. A sent message is not reviewer acceptance.

An existing explicitly authorized supervisor may notify only on a new
actionable result for an approved Goal and a known idle/stable recipient;
suppress duplicate blocker wakes. It **cannot** authorize work, change policy
or expand scope. Do not build a watcher, poll loop or unattended daemon simply
to support this Goal; deployed wake systems require their own safe-mode
validation and operational ownership.

## Citations

- [V2 #15 observed checks and unresolved trigger effects](https://github.com/amitkarpe/ami-factory-v2/issues/15#issuecomment-6399777193)
