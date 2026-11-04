---
type: Playbook
title: OpenCode Quick Start, Model Selection and Worker Recovery
status: candidate
confidence: medium
scope: OpenCode V2 model selection, headless sessions, JSONL, liveness and artifact acceptance
review_after: 2027-01-28
tags: [opencode, opencode-v2, workers, jsonl, sessions, recovery]
---

# OpenCode: Models, CLI and Worker Recovery

> **Use OpenCode V2 only.** This guide was verified on `opencode v2.2.0` on
> 4 Nov 2026. V1 commands, V1 `/docs/...` pages, `--variant`, and the old
> `--attach` form are legacy. If `opencode --version` is not v2.x, upgrade
> before following this guide.

The owning project selects provider/model, permissions, execution directory and
task authority. Neither `--auto` nor a model name grants broader access.
Use [Goals and Delegation](../GOALS.md) for the shared task/result contract.

## Quick start: OpenCode Go models (reviewed 4 Nov 2026)

**One canonical entrypoint:** this file covers model selection and worker recovery.
The owning host's native OpenCode configuration remains the runtime source of truth.
Model availability, variants, subscriptions, and pricing can change. Check them
with the installed OpenCode version and the active OpenCode Go account.

### Connect and inspect

```bash
opencode --version
opencode auth list                 # providers and method names; never publish credentials
opencode models | grep '^opencode-go/'   # confirm the actual model IDs
opencode                            # starts the terminal UI; use /models
```

In the terminal UI use `/connect` to authenticate **OpenCode Go**, then
`/models` to choose an available model. Do not paste tokens into a repository
file, shell command, issue, or captured terminal log. OpenCode Go lists
DeepSeek V4.1 Flash and GLM-5.3-Flash in its current official model catalog.
The provider/model identifiers below are **proposed examples**; confirm the
exact output of `opencode models` before storing them.

### Headless login (device code)

`/connect` is TUI-only. On a headless VM use the Console device flow:

```bash
opencode auth login opencode --method device
```

It prints a one-time code and a URL shaped like:

```text
Enter code: XXXX-XXXX
https://opencode.ai/console/device?user_code=XXXX-XXXX&client_id=opencode-cli
```

Open the URL, sign in to the OpenCode Console account that owns the Go plan,
and approve. The command ends with `Connected to OpenCode Console`. The code is
one-time; do not commit it or paste it into a log. On the home host this exact
flow worked from a headless VM: the VM printed the code and URL, and the
browser approved it.

To connect the Go provider directly with an API key instead:

```bash
opencode auth login opencode-go --method key
```

Paste the key from the Console Go page. The `opencode-go` integration has only
key/environment methods; `device` belongs to `opencode` (OpenCode Console).

Amit's current plan is **Go at $10/month**. Go Plus ($40/month) and Go Teams
($20/member/month) have different limits; verify the plan in the Console.

### Choose the default and reasoning variant

**Preferred:** DeepSeek V4.1 Flash as the interactive default, with `high`
reasoning **only if that model/provider exposes the variant**. Not every
model supports every reasoning level. `max` and `high` are not interchangeable
provider guarantees.

OpenCode reads the root `model` property in `opencode.json` or
`opencode.jsonc`. An example, **not deployed by this guide**:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "opencode-go/deepseek-v4.1-flash"
}
```

A global preference belongs in the machine's own OpenCode config. A repo-local
config is only appropriate when that repo has approved that preference. In V2
the `model` value can be a string `provider/model#variant` or an object with a
`variant` field; omit the suffix when you do not want to pin a variant.

Use explicit arguments for one-off runs:

```bash
opencode run --model 'opencode-go/deepseek-v4.1-flash#high' "Summarize this repository; read only."
opencode run --model 'opencode-go/glm-5.3-flash#high' "Summarize this repository; read only."
```

In V2.2.0, `opencode run --model` accepts `provider/model#variant`. There is
no separate `--variant` flag. First verify `opencode run --help` and an
inexpensive read-only response. Both DeepSeek V4.1 Flash and GLM-5.3-Flash
expose `low`, `high`, and `max`; if a model does not expose `high`, omit the
suffix. Do not label a default response 'high' without proof.

### Secondary choice: GLM-5.3-Flash

```bash
opencode run --model opencode-go/glm-5.3-flash "Summarize this repository; read only."
```

**Fallback is a decision, not an automatic promise.** The legacy `small_model`
key is **deprecated** in the V2 schema; do not set it. It was never a
guaranteed failover target for the main model. No verified built-in config
entry automatically switches a failed DeepSeek task to GLM.

On a provider rate limit, auth failure, unsupported variant, or interrupted
run: preserve the original session and evidence; reconcile any side effects;
then explicitly choose GLM for a **new approved bounded attempt**. Do not
silently replay a state-changing prompt or launch duplicate workers. A
task already in progress keeps its stated ownership, budget, and permissions.

### Five-line decision table

| Need | Selection | Guard |
| --- | --- | --- |
| Everyday interactive work | DeepSeek V4.1 Flash | Set `model` once in native config |
| One deeper task | DeepSeek V4.1 Flash + `#high` | Verify `high` exists before use |
| Provider unavailable | GLM-5.3-Flash | Manual selection after reconciling original session |
| Lightweight helper work | No `small_model` in V2 | Deprecated; do not set it |
| Exact reproducible worker | Explicit `--model provider/model#variant`, session, cwd | Verify artifacts; never infer success from exit 0 |

### Doer and adviser pattern (field note)

In the October 2026 19-lane safe-point work (#596), an OpenCode session was the
doer and a separate Claude/GLM session was the read-only adviser. The pattern
that worked:

- **One writer.** The doer owns the branch, runs the commands, opens the PR,
  and reports evidence. No duplicate worker.
- **Read-only adviser.** The adviser can flag a wrong assumption, a missing
  proof, or a cheaper path. It cannot approve, merge, run a job, or change a
  file.
- **Durable handoff.** The owning Issue or PR comment is the record. A direct
  OpenCode message is only a wake; `QUEUED` is not `read`.
- **Evidence over agreement.** The adviser found that a gate checked the wrong
  registry and that the per-lane proof did not show the offline assertions.
  The doer fixed both and re-ran the gate. The adviser did not take over.
- **Owner scores.** The merge gate is 90% or more. Human-only decisions
  (credentials, IAM, branch protection, cost) stop the doer.

The adviser is optional. The doer remains fully autonomous inside the approved
scope and does not wait for an approval message.

### Which files should remain?

- **Keep this file** as the one OpenCode topic in Agent OS.
- **Deletion candidate, not approved:** the older
  [dotfiles OpenCode contract](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/OPENCODE.md).
  Audit global loaders, `oo` wrapper usage, and unique host/runtime guidance
  before deleting or replacing it with a short pointer. Cross-repository
  deletion belongs to a separate reviewed action.
- **Do not delete** `README.md`, `GOALS.md`, `codex/DELEGATION.md`, or
  project-specific agent rules. They have distinct readers and authority.
- No second OpenCode model guide is needed in this repository. Changing a
  real host's default model requires a separate host-configuration change.

Official references (V2 only): [OpenCode CLI](https://opencode.ai/v2/docs/cli/),
[Models and variants](https://opencode.ai/v2/docs/models/),
[Configuration](https://opencode.ai/v2/docs/config/),
[CLI providers](https://opencode.ai/v2/docs/cli/providers/), and
[OpenCode Go catalog](https://opencode.ai/v2/docs/console/go/).

## Launch contract and output

Record the exact cwd/repository/HEAD, allowed tools/files, expected artifacts,
session identity and completion evidence. Supply prompt **content** and keep
stdout/stderr separate. The following shape is for OpenCode V2 (checked on
v2.2.0); run `opencode run --help` on the installed version before use:

```bash
prompt_text=$(cat "$reviewed_prompt_file")
( cd "$approved_repo" && opencode run \
    --model "$approved_provider_model" \
    --format json "$prompt_text" \
    > "$private_jsonl_file" 2> "$private_stderr_file" )
```

In V2, `--model` accepts `provider/model#variant`. There is no `--dir` flag in
`opencode run` v2.2.0; change directory explicitly.

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
successful model reply.

For V2, use `opencode service status`, `opencode api get /api/info`, and the
documented `--server` or `--standalone` options. Do not use the V1 `--attach`
form or old manually configured ports. Bind any authorized server to the
approved local-only interface; do not expose it externally for convenience.

## Citations

- [Legacy dotfiles OpenCode contract - deletion candidate](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/OPENCODE.md)
- [OpenCode V2 CLI reference](https://opencode.ai/v2/docs/cli/)
- [OpenCode V2 API reference](https://opencode.ai/v2/docs/api/)
- [OpenCode V2 ACP support](https://opencode.ai/v2/docs/cli/acp/)
