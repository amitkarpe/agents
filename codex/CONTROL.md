---
type: Playbook
title: Repository-First Local Agent Control
description: Make controller-to-worker attachment boring by discovering active local workers from repository identity and using durable external control when direct attachment is unavailable.
status: reviewed
scope: local agent orchestration
confidence: medium
timestamp: 2026-09-30T00:00:00+08:00
review_after: 2026-12-31
tags: [controller, worker, codex, kiro, crew, github, local-runtime]
---

# Repository-First Local Agent Control
> **Scope:** Specialist implementation reference, not permission to install,
> access a private host, deploy infrastructure or run a paid browser provider.
> Follow the active project's Goal and [canonical Core](../AGENTS.md),
> [Goals](../GOALS.md) and [Testing](../TESTING.md).
> Validate current tool capabilities on the actual execution host.


## Problem

Local coding agents often already exist before the controller arrives. A new
controller session should not require manual session UUIDs, private registry
editing, or another worker just to attach to the first worker.

The recurring failure mode is a **bootstrap paradox**:

```text
worker already running
-> controller cannot see it because a private lane is missing
-> another worker must register the lane
-> controller retries
```

That is operationally expensive and makes every new repository feel like a
fresh integration project.

## Principle

Use the Git repository as the primary identity.

Prefer:

```text
controller knows owner/repo
-> discover exact matching local Git checkout
-> prefer the unique active worker whose cwd resolves to that checkout
-> register/refresh the private lane automatically
-> attach
-> execute
```

Human thread/worktree names are secondary identity. Runtime session UUIDs are
internal plumbing and should not be normal operator input.

If more than one matching worktree or active worker exists, return a short
candidate list instead of silently choosing.

## Keep the manual primitive, not the manual workflow

A bounded explicit registration operation remains useful as a fallback and for
diagnostics. It should not be the daily path.

Daily controller UX should be closer to:

```text
open_worker(repository)
-> mission_start(...)
```

than:

```text
list registry
-> inspect filesystem
-> copy checkout path
-> copy session UUID
-> register
-> restart
-> retry
```

## Durable fallback control

When direct controller-to-worker attachment is unavailable, use a durable
external inbox rather than terminal prompt injection.

A useful pattern is:

```text
controller
-> durable issue/comment command
-> tiny local poller
-> persistent local task runner
-> worker
-> branch/PR/evidence
```

GitHub or another durable work queue becomes the control bus. The local poller
should be deterministic, cheap, idempotent, and independent of the model.

The task runner, not the browser or tmux pane, owns long-running execution.

## Long-running local workers

For unattended work:

- use a persistent local process manager or task runner;
- make browser and terminal attachment optional;
- persist task identity and checkpoints;
- reconcile uncertain dispatch before retrying;
- return durable evidence to the owning Issue/PR.

A visible terminal pane is an observation surface, not proof that the worker is
healthy or persistent.

## Separate control from execution capability

Controller attachment and execution authority are different concerns.

A controller may successfully attach to a worker while that worker lacks cloud
credentials, tool access, or mutation authority. Prove each layer separately:

1. controller can address the intended worker;
2. worker can start and report a durable task;
3. task can access required local tools;
4. cloud identity is the intended account/role;
5. a harmless create/read/delete smoke test succeeds when mutation is required.

For local cloud development, prefer inherited named profiles or short-lived
local credentials over copying secrets into the control plane.

## Acceptance ladder

Use this minimal ladder for a new controller path:

1. **Attach:** fresh controller attaches using only repository identity.
2. **Read:** one harmless repository read succeeds.
3. **Task:** one durable local task starts and reports state.
4. **Tool:** required local CLI/tool is visible inside the task.
5. **Cloud identity:** read-only identity check matches the intended account.
6. **Mutation:** one disposable low-cost create/read/delete cycle succeeds.
7. **Repeat:** repeat the smoke test enough times to detect one-off flukes.
8. **Evidence:** result is written back to durable project state.

Do not call the path ready because configuration exists. Call it ready when the
evidence chain exists.

## KISS rule

**Repository first. Discover automatically. Attach once. Persist the task.
Prove execution separately.**

Avoid turning local agent orchestration into a security or registry project
unless the environment actually requires it.
