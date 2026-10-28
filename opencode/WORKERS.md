---
type: Playbook
title: OpenCode Worker Evidence and Recovery
status: candidate
confidence: medium
scope: Portable headless sessions, JSONL, liveness and artifact acceptance
review_after: 2027-01-28
tags: [opencode, workers, jsonl, sessions, recovery]
---

# OpenCode Worker Evidence and Recovery

The owning project selects provider/model, permissions, execution directory and
task authority. Neither `--auto` nor a model name grants broader access.
Use [Goals and Delegation](../GOALS.md) for the shared task/result contract.

## Launch contract and output

Record the exact cwd/repository/HEAD, allowed tools/files, expected artifacts,
session identity and completion evidence. Supply prompt **content** and keep
stdout/stderr separate. The following shape preserves the pinned
**2026-07, OpenCode 1.18.3-era** workflow; flags must be checked against the
installed version before use:

```bash
prompt_text=$(cat "$reviewed_prompt_file")
opencode run --dir "$approved_repo" --model "$approved_provider_model" \
  --format json "$prompt_text" \
  > "$private_jsonl_file" 2> "$private_stderr_file"
```

No default model, effort variant or blanket permission override is implied.
Do not put secrets in command-line prompts. The source's fixed staged timing
and model preferences remain local/dated observations, not mandatory global
planning gates. Use phases only when task risk or a genuinely missing decision
requires them; an already-approved implementation need not wait for repeated GO.

## Read JSONL defensively

JSON mode emits events, not one JSON document. Keep the raw stream and stderr;
a compact summary must not replace them. An illustrative read of recorded
events is:

```bash
jq -c 'select(type == "object")
       | {type, sessionID, error}' "$private_jsonl_file"
```

The available fields depend on version/event type. Validate actual schemas
before automation; a missing `sessionID` in one event is not proof of no
session. A truncated final line, unknown event, tool failure or provider
backoff requires reconciliation, not silent discard. Do not interpret the last
line alone as authoritative completion.

Bind the session ID to the known task/cwd. A successful CLI exit does not prove
a reply or artifact; assert required files/content and the owning acceptance
checks independently. Source observations included exit 0 with no final
artifact and interrupted runs that also appeared successful.

| Observation | Classification/action |
| --- | --- |
| Valid final reply + required artifact/checks | Candidate result; controller accepts exact artifact |
| Exit 0, no required output | Invalid/incomplete; preserve stream and diagnose |
| Quiet stream with known active session | Liveness unknown; bounded observation |
| Provider rate-limit/backoff event | Provider limitation; no automatic provider/model fallback |
| Interrupted or cancelled run | Preserve partial artifacts; reconcile before resume |
| Wrapper timeout or signal exit | Record wrapper/signal context; code alone is not workload outcome |

Codes such as 124, 137 and 143 can reflect wrappers or signals; they are not
universal provider result codes.

## Resume without losing ownership

Use the exact known `--session` and original cwd for versions that support
them. Do not use “most recent”/`--continue` when several sessions exist.
Do not overlap turns on one session. A fork is a deliberate new lineage,
not recovery of the same result.

A dated attempt to resume a known session from a different directory stalled
before useful JSON events. Return to the original cwd after reconciling the
existing attempt, rather than spawning another session to work around it.
Preserve the original failure evidence and partial files.

Session export is evidence/backup, not proof that importing or replaying it is
safe. If a version offers sanitization, inspect the export before publication:
automatic sanitization does not guarantee removal of private paths, payloads
or identifiers. Never publish raw session exports.

## Liveness, waiting and cancel authority

Set an explicit monitoring/deadline contract appropriate to the task. If the
owner selected no execution timeout, retain it; this is distinct from how often
the controller reports status. Historical five-, ten- or sixty-minute phases
are not universal stop thresholds.

Sparse output can reflect long tool work or provider retry. The source
observed `step_start` followed by rate-limit retries, so “no new JSON” alone
did not establish a dead worker. Inspect only authorized existing session/process
status and relevant private error summaries. Do not add live canaries, another
worker or a paid fallback merely to investigate quiet output.

If cancellation is authorized, prove ownership of the exact process/session.
For a deliberately isolated process group, record its leader/PGID at launch,
then verify its membership and that it is not the controller's group before
signalling it. For an owned PID, verify command/cwd/start identity before any
signal. Never use broad `pkill -f`, a guessed negative PID or an unrelated
service restart. Cancellation and cleanup are separate authorities.

## Document generation and acceptance

For a complex DOCX task, a useful bounded split is:

1. produce the requested source/generator and candidate document;
2. run the owning deterministic validator/render workflow;
3. inspect ZIP/document structure, required text, images and prohibited content;
4. visually inspect the rendered pages and bind acceptance to exact outputs.

Do not require a model to prove the entire end-to-end workflow by assertion.
A generator file without its output is incomplete when the contract requires
both. A document opening successfully does not prove layout or content.

The pinned July 2026 observations included several concurrent document workers
stalling while a bounded single worker completed. Isolated trials had different
latencies. Those samples justify diagnosing concurrency/evidence availability;
they do not establish a provider capacity limit, price, fastest model or
universal worker count.

## Server, attachment and ACP distinctions

A headless server, a client attaching to it, and ACP over stdio are different
interfaces. A running local listener proves neither a usable session nor a
successful model reply. Bind any authorized server to the approved local-only
interface; do not expose it externally for convenience.

The source observed a no-reply `--attach` path on version 1.17.13 and explored
HTTP configuration/session endpoints. Treat that as dated failure evidence,
not a current API guarantee or a reason to start a service. Consult current
CLI/server/ACP documentation for the selected interface. Do not import the
source's local ports, auth configuration or service setup.

## Citations

- [Pinned OpenCode procedures and observations](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/OPENCODE.md)
- [OpenCode CLI reference](https://opencode.ai/docs/cli/)
- [OpenCode server interface](https://opencode.ai/docs/server/)
- [OpenCode ACP support](https://opencode.ai/docs/acp/)
