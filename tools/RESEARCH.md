---
type: Practice
title: Public-source Grok and X Research
status: reviewed
scope: Public-safe reusable specialist guidance
confidence: high
review_after: 2027-04-23
tags: [research, sources, grok, x]
---

# Public-source Grok and X Research

Choose the least costly **approved** route that can produce the necessary
source evidence. Subscription-backed search, separately metered API usage and
offline archives are distinct. Do not turn failed subscription authentication
into an unapproved paid API fallback.

## Bounded route

One narrow question, a defined time window, bounded search calls and outputs,
and a concise durable result. Require exact source URLs and observed tool
counts; model descriptions of tool use do not prove actual usage. Stop on
missing authentication rather than viewing private key stores or initiating
unapproved recovery.

## Accept or reject the evidence

- Every material X/social-source claim cites the **canonical exact post URL**.
- Independently verify creation time; the X post ID can encode a timestamp,
  but decoding alone does **not** prove the post still exists or supports a claim.
- Record query window, successful and failed calls, source counts, usage/cost
  when available, and observed errors; stop if a limit was exceeded.
- Reject malformed, contradictory, unverifiable, URL-free, future-dated, or
  failed results, and keep raw credentials/cookies/headers/private paths out
  of shared evidence.
- Prefer replay of already captured public evidence for validator testing over
  repeated live calls.

A social result is a research lead, not authority for financial transactions,
credentials, security changes, or production operations. Those decisions need
independently authoritative sources and the owning approval gate. Private
provider account/model routing stays in its dotfiles/native owner.

## Separate archive lookup, social reads and inference

| Route | Evidence and authority |
| --- | --- |
| Existing local archive | Deterministic lookup when the command is documented as such; prove archive/index scope and freshness |
| Authenticated social API read | Exact posts/search results under the selected app/user scope and usage budget |
| Model research/tool search | Explicitly authorized inference plus potentially charged tools; inspect returned sources and usage |

The pinned source used the following **dated CLI examples**; verify the owning
tool's current help before running them:

```text
ft status
ft search "deployment evidence"
ft show <post-id>
xurl read <exact-post-url> --auth app
xurl search "deployment evidence" -n 3 --auth app
```

An archive belonging to another user may be absent, stale or unauthorized;
do not copy/sync it or reuse that user's credentials to make a command work.
Archive status should establish which collection and time window were actually
available. An empty archive is not negative evidence about the wider world.

Commands such as `ft ask` invoke inference in the source workflow. Inspect
`ft wiki` and other convenience commands before treating them as offline or
deterministic. The command name alone does not prove no network or model cost.
The executable archive client and its wrappers remain with their codeowners.

App authentication, user OAuth, a web subscription and API billing are distinct.
App-level post access does not imply user bookmark permission. A usable web
subscription does not grant API credits. If the selected route is unavailable,
stop and report the exact gap; no credential sharing, cross-user wrapper or
automatic paid fallback.

## Inference budgets and durable evidence

Before an approved inference/search task, define the question, source/date
window, maximum authorized calls/spend and output. A prompt asking for “at most
three calls” is a hint, not an enforced provider limit. Use supported runtime
limits where configured, inspect actual returned tool usage, and stop/report
unexpected calls or budget uncertainty rather than starting a second research
loop. Do not infer current prices or model context limits from the source's
May/July 2026 observations.

Record query, retrieved exact URLs, timestamps, source excerpts/claim bindings,
failed calls and actual usage fields privately as needed. A model saying it
searched does not prove a tool call. Historical source code interpreted
`usage.cost_in_usd_ticks / 1e10` as USD; verify the current provider schema and
billing semantics before using that conversion. Estimated, reported and billed
cost are distinct. Do not publish raw private archive content or credential
headers as evidence.

For financial/security/production decisions, use social material as leads and
corroborate with authoritative sources; research output creates no execution
authority.

## Official documentation without an extra research loop

Use the selected official documentation route for product facts. A docs MCP,
an official Markdown endpoint or a bounded cached page can avoid unnecessary
model research. Verify page identity, date/version and cache freshness. Do not
guess a `.md` URL works, treat a cached claim as current, copy entire manuals
into the knowledge base or edit a built-in skill to store local routing.
OpenAI-specific provider adapters and cache/helper paths remain locally owned.

## Citations

- [xAI search tools](https://docs.x.ai/docs/guides/tools/search-tools)
- [xAI API](https://docs.x.ai/)
- [X API post IDs](https://docs.x.com/fundamentals/x-ids)
- [Pinned archive, social and inference procedures](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/services/XAI_X_SETUP.md)
- [Pinned official-docs routing](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/OPENAI_DOCS.md)
