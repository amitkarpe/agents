---
type: Policy
title: Agent Tool Routing
description: Select exact, proportionate tools for discovery, parsing, validation, and evidence.
status: reviewed
scope: Reusable public-safe local tool selection
confidence: high
timestamp: 2026-10-21T18:35:00+08:00
review_after: 2027-04-21
tags: [agents, tools, discovery, validation, evidence]
---

# Tool Routing

Choose the smallest tool that answers the question and keep the final proof
from an exact source. Tool availability is environment-specific; discover the
installed command when needed and stop if the required capability is absent.

## Default routes

| Need | Route | Boundary |
| --- | --- | --- |
| Search tracked text | `git grep` | Use `rg` only after constraining its input to an authoritative tracked-file list. |
| Find paths | `fd` or a narrow `find` | Do not use content search to answer a filename question. |
| Repository truth | `git` | Check identity, branch, HEAD, dirty state and diff before edits. |
| Structured data | A format-aware parser | Validate the parsed result; do not infer structure from text matches. |
| Shell/config syntax | The interpreter that will parse it | Validate both wrapper and payload when there are two interpreters. |
| Network/provider state | The owning CLI or API | Distinguish documentation or metadata from live account/resource proof. |
| Long work | A bounded, resumable command | Record durable state; a watcher or dashboard is not completion proof. |

Use exact output for machine decisions. Search indexes, summaries, dashboards,
and convenience reductions can locate evidence but do not replace the source
read. Keep credentials, authentication state and private payloads out of
commands, logs and tracked guidance.

For reusable procedures, start with [Git-aware repository
search](tools/RECIPES.md) and [practical
agent tool recipes](tools/RECIPES.md).
For browser proof, use the [browser E2E and screenshot
playbook](tools/BROWSER.md).
Provider-specific tools and host bootstrap belong in their local adapters, not
this public inventory.
