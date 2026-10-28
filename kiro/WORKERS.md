---
type: Playbook
title: Bounded Kiro Worker Sessions
status: candidate
confidence: medium
scope: Portable Kiro task scope, artifacts and recovery
review_after: 2027-01-28
tags: [kiro, workers, sessions, recovery]
---

# Bounded Kiro Worker Sessions

Use the owner-selected provider, model, effort and authentication. A CLI role,
agent profile or mode does not grant project authority. Apply
[Goals and Delegation](../GOALS.md) for the task contract; native Codex transport
has its own [protocol](../codex/DELEGATION.md).

## Establish identity and scope

Record the exact execution directory, repository/HEAD, task/session ID,
allowed reads/writes, expected artifacts, and stop condition. Use only the
configured approved tools and narrow file permissions. MCP configuration,
successful login and actual callable tool permission are distinct facts.

For a CLI/version that supports the pinned chat interface, the command shape
was:

```bash
prompt_text=$(cat "$reviewed_prompt_file")
(
  cd "$approved_repo" || exit
  kiro-cli chat --no-interactive --wrap never "$prompt_text"
) > "$private_stdout_file" 2> "$private_stderr_file"
```

This is a **dated 2026 source example**, not a claim that today's CLI has the
same flags or session format. Check installed help/official version docs
before execution. Permission setup must already satisfy the write/tool
allowlist; noninteractive operation is not approval to grant all tools.
Pass actual prompt content, not a filename that the worker may interpret as the
task. Do not expose secrets through prompt arguments or output logs.

Include essential evidence in the prompt or in explicitly readable files.
Listing a private controller-only evidence path does not make it available to
the worker. Use the smallest relevant context; avoid forcing a worker to
rediscover inaccessible facts.

## Artifact contract

For a document/HTML task, state exact outputs, required sections, forbidden
content and the designated write tool. If shell/Python execution is outside
scope, prohibit it explicitly rather than trusting a role name. The worker may
produce candidate artifacts only; the owner validates:

1. the intended files exist, are nonempty and changed in the correct checkout;
2. required content/format and prohibited/private content checks pass;
3. links/assets resolve and existing structural checks pass;
4. rendered HTML or slides are visually inspected where appearance matters;
5. evidence/result identifies the exact artifact and remaining limitations.

Use [Presentations](../tools/PRESENTATIONS.md) for presentation proof. Executable
skills/generators stay with their codeowners; do not copy them into this guide.

## Exact-session recovery

The pinned interface used `--resume-id <session-id>`. Verify that interface for
the installed version, then resume the known session from its original cwd.
Do not select an arbitrary “latest” session, create a replacement silently or
run two turns concurrently against the same session.

A bounded correction should name the failed artifact, available evidence and
allowed operation. Preserve original output/error. A successful textual reply
or process exit is not artifact acceptance.

### Dated failure lessons

- **2026-07-07:** a document worker announced write intent but attempted an
  unavailable shell/heredoc path. Broad trust settings did not fix tool
  availability. An exact-session corrective instruction restricting the
  operation to the available write tool produced the artifact. Preserve the
  mechanism: reconcile callable tools and file scope; do not escalate trust.
- **2026-07-23:** a review spent extra effort trying to read evidence paths it
  could not access. Embed the essential sanitized evidence or grant the
  already-approved exact read, rather than raising effort/model by default.
- A diagram import in the source used `diagrams.onprem`; an attempted
  `onpremise` namespace failed. Check the installed package/API and render the
  actual diagram. A plausible import or generated source is not render proof.

These observations do not select a current model, promise timing, authorize a
new probe or imply that a historical session can be resumed on another host.

## Liveness and cancellation

Use the already-approved monitoring route and bounded readbacks. Quiet output
can mean tool work, provider backoff or a stalled process; distinguish those
from evidence already available. Preserve UNKNOWN when the session's outcome
cannot be read. Do not resend the original task to obtain a cleaner receipt.

Cancel only with owning authority and exact session/process ownership. Never
kill processes by a broad name match or treat an elapsed example duration as
cancellation permission. Preserve partial artifacts and evidence for recovery.

## Citations

- [Pinned Kiro procedures and failure observations](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/KIRO.md)
- [Kiro CLI chat documentation](https://kiro.dev/docs/cli/chat/)
- [Diagrams on-premises providers](https://diagrams.mingrammer.com/docs/nodes/onprem)
