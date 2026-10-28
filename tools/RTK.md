---
type: Practice
title: Lossy Command Output and RTK Boundaries
status: candidate
confidence: medium
scope: Human review versus machine and audit output
review_after: 2027-01-28
tags: [tools, rtk, output, evidence]
---

# Lossy Command Output and RTK Boundaries

Output compression can reduce review cost, but a summary is not the original
result. Use the approved installation only where the consumer tolerates omitted,
reordered or reformatted data. Installation, hook enablement and telemetry
configuration remain local; this guide does not authorize changing them.

## Select the output contract first

| Consumer | Route |
| --- | --- |
| Human skim of status, diff or familiar test summary | RTK may help; open raw detail when needed |
| JSON parser, exact counts, inventory, pagination or final gate | Native raw output with explicit query |
| Durable audit evidence, command stdout/stderr, SSM output | Preserve original raw output |
| Mutation or retry decision | Native result and exact IDs; a summary cannot supply missing certainty |
| Long-lived watcher writing a result consumed later | Stable raw format; no lossy wrapper in the producer |

For a supported local version, review-only examples include:

```bash
rtk git status
rtk git log -5
rtk git diff
```

Check installed help before assuming a particular subcommand/flag exists. For
search and structured APIs, first reduce scope at the producer: a tracked path,
literal query, service-side filter or native `--query`/`--output`. See
[Recipes](RECIPES.md). Do not wrap a native JSON result if a parser expects JSON.

## Failure modes and raw recovery

- Arrays may be shortened into text such as `... +N more`. That is neither
  valid complete JSON nor a complete inventory. Do not count visible rows.
- A compact success line can hide warnings or relevant stderr. Use the original
  exit status and required output assertions, not a pleasing summary.
- Filtering logs before persistence loses evidence. Preserve raw output in
  approved private storage; derive a compact, sanitized review separately.
- An RTK shell integration does not transform an MCP tool's native structured
  response. A configured hook also does not prove the current client used it.
- A raw-pass-through/proxy facility is version-specific. Prefer the native
  command when output identity matters; verify byte/format preservation before
  treating any wrapper as transparent.

For example, native AWS JSON queried to the exact fields is appropriate for a
machine consumer; an RTK AWS display is only a human view. No AWS execution is
authorized by this example. When a compressed result is insufficient, perform
the authorized **read** by exact resource/request ID; never replay a mutation
merely to obtain prettier output.

## Measure value without creating overhead

The pinned 2026 source used `rtk gain` and version-specific variants such as
`-p`, `-H`, `-a` and `-F` to inspect savings. Verify local help before reuse;
these are dated diagnostic examples, not a portable flag guarantee.

Compare representative approved work against raw output: retained useful
detail, token reduction, latency and whether recovery reads erase the gain.
Do not confuse a tool's estimated savings with provider-billed usage. Stop
wrapping commands that save little or break the output contract. Do not add a
per-turn measurement ceremony or change telemetry just to prove RTK usage.

## Historical scope

The source contains installation/version observations and old archive/retention
dates. They establish provenance only. A date passing does not authorize
deletion, process termination, reinstalls or configuration migration; use
[Knowledge retention](../KNOWLEDGE.md) and the owning project decision.

## Citations

- [Pinned RTK practices and observations](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/RTK.md)
- [RTK upstream documentation](https://github.com/rtk-ai/rtk)
