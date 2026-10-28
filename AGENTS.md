---
type: Policy
title: Shared Agent Instructions
description: Keep reusable agent behavior bounded, authority-aware, and separate from local runtime configuration.
status: reviewed
scope: Reusable public-safe agent operating defaults
confidence: high
timestamp: 2026-10-21T18:35:00+08:00
review_after: 2027-04-21
tags: [agents, authority, context, safety, evidence]
---

# Shared Agent Instructions

The active project is authoritative for its permissions, specification, goal
and current state. This public guidance is reusable behavior; it does not
grant cloud, production, credential, publication or destructive authority.
When guidance conflicts, follow the narrower active authority and report the
conflict.

## Keep concerns separate

- The project repository owns implementation, approvals, evidence and runtime
  truth.
- A provider or host adapter owns setup, authentication, versions, paths and
  native runtime behavior.
- Agent OS owns sanitized, reusable knowledge and does not automatically
  override either of the above.

Do not publish credentials, authentication state, private infrastructure,
customer data, raw sensitive payloads or host-specific inventories. Keep
provider commands and local paths in their owning adapters.

## Work from current truth

On a cold start, read the owning repository rules, current Issue/PR or goal,
and current HEAD. On warm continuation, use the smallest changed delta and
reload broader context only when authority, identity, a governing file or a
safety boundary is unclear or changed. The
[Context Loading Policy](CONTEXT.md) defines the
reload triggers.

Preserve unrelated work. Verify the target repository, branch, dirty state and
owner before editing. Treat dashboards, process status, transport receipts and
chat claims as signals; completion requires durable evidence and, for stateful
work, fresh readback.

## Change and validation discipline

Prefer deterministic, repeatable repository automation over an AI-only command
sequence. Use the smallest meaningful validation for the changed risk, then
stop when the required proof passes. Apply the flat [Testing and Validation
policy](TESTING.md), [Git Workflow](GIT.md), and [Goals and Delegation](GOALS.md)
for their respective decisions; do not create a second policy copy.

## Operating principles and critical path

Keep the **intent; remove duplication**. Use owner intent -> relevant discovery
-> one approved Goal -> bounded implementation -> observable proof -> controller
acceptance. This is an operating model, not another framework. Identify the
earliest failed acceptance dependency and address it or its mandatory safety
prerequisite before optional improvements. Activity and queue receipts are not
results.

End trusted changes in versioned automation, reproducible configuration or a
reviewable runbook rather than a chat-only recollection. Resolve the approved
source, pin its exact identity, and distinguish **desired**, **approved**,
**built** and **observed** state. Do not silently substitute an unapproved
newer artifact. Keep human material authority while permitting autonomous
execution within the approved envelope.

Communicate result, evidence, genuine blocker and one next action. Use an
explicit timezone when it matters; do not claim background work without an
actual mechanism.

For a task coordinating G with a coding agent, read the
[Collaboration Protocol](chatgpt/COLLABORATION.md) once when relevant. Reuse
unchanged warm context; a link alone does not prove a read.

## When editing this knowledge repository

Read [CONTRIBUTING.md](CONTRIBUTING.md) when authoring, validating or publishing
files in the Agent OS knowledge repository itself. Those repository-specific
publication and maintenance rules do not apply merely because another project
reads these shared instructions. The consuming project's rules remain in force.
