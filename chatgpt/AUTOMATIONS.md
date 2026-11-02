---
type: Playbook
title: ChatGPT Event-Triggered vs Scheduled Tasks
description: Choose webhook-driven Work tasks for supported external events and scheduled tasks for time-driven work, while preserving approval and durable-state boundaries.
status: reviewed
scope: ChatGPT Work and Scheduled tasks
confidence: high
timestamp: 2026-09-16T02:00:00+08:00
last_verified: 2026-09-16
review_after: 2026-12-16
tags: [chatgpt, work, tasks, github, webhooks, automation]
---

# ChatGPT Event-Triggered vs Scheduled Tasks
> **Ownership:** This specialist guide documents one bounded topic. The
> canonical [Core](../AGENTS.md), [Goals](../GOALS.md),
> [Context](../CONTEXT.md) and [Safety](../SAFETY.md)
> rules govern reusable authority and evidence. Project rules and local
> provider/host configuration still take precedence. A documented command or
> reference is not proof of current runtime support.


Use the trigger that matches the source of truth:

```text
external supported event -> event-triggered Work task
clock/time requirement    -> scheduled task
durable result/state      -> owning system such as GitHub
```

## Documented Product Model

- Event-triggered tasks are webhook-based, run in Work, and can respond to
  supported Gmail, Slack, or GitHub activity.
- GitHub event-triggered tasks operate on pull request activity in an authorized
  `github.com` repository. Supported activity can include PR open/ready/close and,
  depending on the configured trigger, reviews, comments, commit updates, or
  completed merges.
- Eligible paid plans can run recurring scheduled tasks up to once per hour.
- Event-triggered tasks can run up to 30 times per hour and 720 times per day
  across the user's event-triggered tasks; multiple events may be grouped.
- Connected-app permissions and workspace controls still apply. If an action
  requires approval, the task can pause until that approval is provided.
- A task created in a Project should not be assumed to have access to uploaded or
  Project-stored files; current OpenAI task documentation explicitly limits this.

## KISS Operating Rules

1. Prefer an event trigger when GitHub can emit the event directly. Do not replace
   a webhook with frequent polling.
2. Prefer a scheduled task for a real clock requirement: reminders, daily/weekly
   summaries, or periodic checks where hourly-or-slower cadence is acceptable.
3. Design unattended automation around actions that can run under existing app
   permissions. Do not assume a previous interactive approval will satisfy a
   future task execution.
4. Keep the durable result in the owning system. For repository automation, use
   the Issue, PR, commit, and CI state as restart/evidence truth rather than an old
   interactive chat.
5. Keep trigger scope explicit. Support for one GitHub PR event does not prove that
   every PR/review/CI event is configured for the task.
6. For read-only monitoring, keep the task read-only unless mutation is explicitly
   required and its approval behavior is understood.

## GitHub Pattern

```text
GitHub PR/review/comment event
        -> Work event-triggered task
        -> read/report current PR + CI state
        -> durable GitHub evidence
```

For cloud/runtime mutation, prefer the execution path that already owns the
required runtime authority, then write durable evidence back to GitHub for later
Work/read-only reporting.

## Empirical Validation Boundary

Issue #20 recorded a successful PR-comment -> Work wake/read/report flow and
additional PR-open/comment/review test events. Treat those repository-specific
results as observations. The reusable rule comes from the documented trigger,
frequency, permission, and approval model—not from assuming every emitted event
was observed by the same configured task.

This complements [Completion Notification without Polling](../GOALS.md): durable state is the result; a wake or notification is a transport mechanism.

## Citations

- https://help.openai.com/en/articles/10291617-chatgpt-tasks
- https://help.openai.com/en/articles/20001275/
- https://help.openai.com/en/articles/11145903
- https://help.openai.com/en/articles/11487775
- https://github.com/amitkarpe/agent-os/issues/20
