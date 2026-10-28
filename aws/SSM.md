---
type: Playbook
title: SSM Run Command and NoReboot Evidence
description: Build exact payloads, send once, reconcile terminal per-target results and preserve patch/runtime evidence.
status: candidate
confidence: high
scope: Authorized SSM Run Command and Patch Manager workflows; no execution authority
last_verified: 2026-10-28
review_after: 2027-01-28
tags: [aws, ssm, payloads, timeouts, patching, evidence]
---

# SSM Run Command and NoReboot Evidence

Start with [AWS identity/source rules](../AWS.md). Use the owning repository's
reviewed wrapper or matching executable skill when available. This document
preserves the operational contract; it does not install those wrappers or copy
their code. All targets, evidence destinations and command bodies below must
be resolved inside an approved task before execution.
The shared `aws-ssm-run-command` skill is one existing executable owner; its
source reference does not prove it is installed on the selected runtime.

## Contract: prepare → send once → wait → collect → validate

1. Verify the exact profile/account/Region, managed-node identity, supported
   document/version, node role, transport readiness and intended write scope.
2. Construct and inspect a durable request/payload. Set a finite appropriate
   execution timeout and expected terminal evidence.
3. Send one request, persist the returned CommandId immediately, and bind it to
   the request, target and start time.
4. Follow that CommandId's per-node/plugin status to a terminal result.
5. Collect stdout/stderr, response code, execution timestamps and any external
   output location; validate the intended effect, not just the exit status.

An aggregated command status can differ from an individual invocation or
plugin. Tag targeting may select no nodes, and a script can mask a failure
with a zero exit. Record actual target membership and inspect all required
invocations. Do not promote an aggregate `Success` to workload acceptance.

If send times out or its receipt cannot be parsed, the outcome is UNKNOWN.
Preserve the request/time/target and reconcile service execution evidence;
do not resend to obtain a convenient CommandId. A known ID is resumed, not
replaced. General no-replay and durable-control rules live in [OIDC](OIDC.md).

## Payload construction and interpreter boundary

Use a JSON-aware constructor and a file for multi-line commands. Keep the
exact payload with the evidence. Do not interpolate secrets or build fragile
nested shell/JSON quoting.

Illustrative `commands.txt`, for an authorized read-only smoke:

```sh
set -eu
uname -a
systemctl is-active amazon-ssm-agent
```

Build parameters from the entire file; JSON escaping is handled by `jq`:

```bash
jq -n --rawfile script commands.txt \
  '{commands:[$script],executionTimeout:["1800"]}' > ssm-parameters.json
```

The 1800-second value is an example budget, not a default for every operation.
Review the rendered payload and run the actual shell's syntax check before
sending. A local Bash shell does not prove the remote plugin interprets the
body as Bash. Use POSIX-compatible outer commands; when Bash is required,
stage an owned script, verify its source/digest and invoke Bash explicitly.
Do not place Bash-only syntax in an outer shell that cannot parse it.

**Authorized send example**:

```bash
aws --profile '<PROFILE>' --region '<REGION>' ssm send-command \
  --instance-ids '<INSTANCE_ID>' --document-name AWS-RunShellScript \
  --parameters file://ssm-parameters.json --timeout-seconds 600 \
  --comment '<BOUNDED_PURPOSE>' --output json > ssm-send.json
jq -er '.Command.CommandId' ssm-send.json
```

Treat output-file protection and redaction as part of the task. For substantial
output, configure the approved S3/CloudWatch output destination before send;
the inline API content may be truncated. Do not silently choose a public
bucket or expose secrets in stdout, comments or command text.

## Timeout layers are different

| Layer | Meaning | On expiry |
| --- | --- | --- |
| SSM delivery/overall timeout inputs | How long the service can try delivery; total behavior also depends on document/plugin execution limits | Inspect `StatusDetails`; a controller timeout is not cancellation |
| `executionTimeout` for `AWS-RunShellScript` | Document parameter used for plugin execution time | Distinguish execution timeout from delivery failure |
| CLI socket/read timeout | How long a client waits for a response | Provider outcome can remain unknown |
| Waiter/operator observation budget | How long the controller observes | Resume the same command later if still active |

Do not describe `send-command --timeout-seconds` as the script's execution
limit or assume its value alone determines total elapsed time. Inspect the
selected document/version; not every SSM document exposes identical parameters.
An infinite wrapper wait never makes the service execution budget infinite.

Source polling profiles used a short-job 10-second poll/1800-second execution
budget and a long-job 300-second poll/10800-second execution budget. They are
tuning examples, not universal service defaults. Choose a finite budget from
expected work and use bounded/event-driven waits with sparse state changes.
Do not run a new send every time an observer stops waiting.

## Wait-only and output-only recovery

For an existing request, keep exact target and CommandId:

```bash
aws --profile '<PROFILE>' --region '<REGION>' ssm list-command-invocations \
  --command-id '<COMMAND_ID>' --details --output json > ssm-invocations.json
aws --profile '<PROFILE>' --region '<REGION>' ssm get-command-invocation \
  --command-id '<COMMAND_ID>' --instance-id '<INSTANCE_ID>' \
  --output json > ssm-invocation.json
```

Use the document's exact plugin name for a multi-plugin invocation when
required; it is not necessarily the document name. A bounded
`aws ssm wait command-executed` or the owning wait wrapper may be suitable,
but a waiter error requires inspection of the same ID, not a repeated send.
Allow for initial service consistency without changing target identity.

Nonterminal observations include Pending, InProgress, Delayed and Cancelling.
Inspect terminal status/details such as Success, Failed, Cancelled,
DeliveryTimedOut, ExecutionTimedOut or other service-specific disposition.
Do not classify a still-running invocation as failed because output is empty.
`ResponseCode=-1` is not a successful script exit.

## Evidence packet

Preserve the exact document/version, target set, request/payload and digest,
CommandId, per-target/plugin status and StatusDetails, ResponseCode,
ExecutionStartDateTime/ExecutionEndDateTime, stdout/stderr or full-output
locations, and the application assertions. Retain the original data before
producing a human summary. Record partial target failures separately.
Public results use sanitized aliases; raw account/instance IDs and payloads
remain in the approved project evidence location.

## Failure triage

| Symptom | First checks | Avoid |
| --- | --- | --- |
| Failed with empty output | Selected document/plugin, rendered JSON, remote interpreter, start/response details, output destination | Assuming no command ran |
| Payload rejected before admission | JSON shape, parameter names/types, file encoding, shell expansion | Resending an admitted operation after an unrelated parse issue |
| Download/path failure; source example exit 23 | Actual failing program, path permissions, source DNS/TLS/auth and private egress | Treating 23 as a universal SSM error definition |
| Exit 124 or timeout detail | Whether an inner timeout utility, plugin execution or service delivery timed out | Increasing all timeouts blindly |
| Cancelled/interrupted | Actor, node/plugin state, already-made effects | Assuming cancellation rolled back writes |
| No credentials / access denied inside command | Node role versus Automation/control role; exact resource permission | Assuming the controller's credentials are inherited by the node |
| Private download unavailable | Approved in-Region S3/internal mirror, endpoint/bucket policy and exact object access | Adding public egress or a new unapproved source |
| Repeated quoting errors | Isolate payload file; validate each receiving interpreter | Nested heredoc/JSON one-liners or unreviewed generated scripts |

Wait-only, output-only and send-with-explicit-timeout paths should remain
separate in an existing wrapper. Missing wrappers are a capability gap to
resolve; a machine-specific path in an old example is not a portable dependency.

## Patch Manager: scan → approved install → same-host proof

For a NoReboot goal:

1. Select exact approved node IDs, baseline/patch policy and patch selection.
   Save a pre-scan and service/runtime health. Prevent overlapping patch jobs.
2. Use `AWS-RunPatchBaseline` with `Operation=Scan` for the initial evidence.
3. Only when installation is authorized, use `Operation=Install` and
   `RebootOption=NoReboot`. Preserve the chosen document inputs and patch
   snapshot identity according to the maintenance-window/project workflow.
4. Wait and collect all per-target results as above. Run a post-scan and
   application/runtime checks on the same node; do not substitute a different
   validation instance.
5. Record MissingCount, FailedCount and InstalledPendingRebootCount plus
   workload assertions. Installed packages and the currently loaded kernel or
   service process can differ.

Approved install request shape (not executed by this guide):

```bash
aws --profile '<PROFILE>' --region '<REGION>' ssm send-command \
  --instance-ids '<INSTANCE_ID>' --document-name AWS-RunPatchBaseline \
  --parameters '{"Operation":["Install"],"RebootOption":["NoReboot"]}' \
  --output json > patch-install.json
```

Post-scan readback includes:

```bash
aws --profile '<PROFILE>' --region '<REGION>' ssm describe-instance-patch-states \
  --instance-ids '<INSTANCE_ID>' --output json > patch-state.json
```

Zero missing/failed patches with a nonzero pending-reboot count means
installation is not yet evidence of reboot-complete compliance. A pending
state can also reflect patches installed outside Patch Manager. Do not reboot
inside a NoReboot goal; use the separately approved maintenance path.
**NoReboot prevents OS reboot, not package-triggered service restarts.**
Protect workload availability accordingly; a successful package install is
not proof that Docker/containerd/application health stayed intact.

## Citations

- [Existing executable Run Command skill](https://github.com/amitkarpe/agent-skills/blob/main/skills/aws-ssm-run-command/SKILL.md)
- [Pinned source payloads, recovery examples and failure lessons](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/ssm.md)
- [Pinned NoReboot source section](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/AWS.md#ssm-patch-manager-noreboot-rule)
- [SSM status, aggregation and timeout semantics](https://docs.aws.amazon.com/systems-manager/latest/userguide/monitor-commands.html)
- [SendCommand reference](https://docs.aws.amazon.com/cli/latest/reference/ssm/send-command.html)
- [GetCommandInvocation reference](https://docs.aws.amazon.com/cli/latest/reference/ssm/get-command-invocation.html)
- [Run Command troubleshooting](https://docs.aws.amazon.com/systems-manager/latest/userguide/troubleshooting-remote-commands.html)
- [RunPatchBaseline and NoReboot](https://docs.aws.amazon.com/systems-manager/latest/userguide/patch-manager-aws-runpatchbaseline.html)
- [Patch compliance states](https://docs.aws.amazon.com/systems-manager/latest/userguide/patch-manager-compliance-states.html)
