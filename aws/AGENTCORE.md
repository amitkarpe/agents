---
type: Policy
title: AgentCore, Harness and Strands Workflows
description: Select AgentCore services and preserve complete bounded Harness and code-owned Strands experiment workflows.
status: candidate
confidence: high
scope: Reusable public-safe agent guidance
last_verified: 2026-10-28
review_after: 2027-01-28
tags: [aws, agentcore, harness, strands, proof]
---

# AgentCore, Harness and Strands Workflows

Use an agent only if the goal genuinely requires model-directed tool choice. A deterministic script or direct API call is simpler for fixed steps. Reading this guide grants no AWS identity, IAM, paid inference, deployment, mutation or production authority.

## Choose the owner of orchestration

| Requirement | Smallest starting point |
| --- | --- |
| Known deterministic steps | Existing script/workflow; no agent framework |
| Model + instructions + allowlisted tools suffice | Consider managed AgentCore Harness |
| Custom orchestration, middleware or code ownership | Code-owned loop such as Strands; Runtime is optional hosting |

Harness runs a configuration-defined managed loop; AgentCore Runtime hosts application-owned code. Do not export/create a codebase just because a service allows it. Check current official AWS availability, versions, pricing and Regions rather than treating dated guides as evergreen.

## Prove one interaction

1. Define one question, expected result and observable evidence.
2. Use synthetic input and one deterministic no-op/read-only tool. Validate accepted arguments and authorization **outside the model**, denying other requests.
3. Prove this boundary locally with the smallest existing check; do not create a test framework. SDK execution may still call a paid remote provider.
4. For **approved** inference, bound tool allowlist, number of calls, loop duration and spending. Keep request/trace identity, validated arguments, tool output and final response. Reconcile an uncertain result before repeating it.
5. For deployments, mutations or long-running AWS operations, apply the separate [durable AWS control](OIDC.md) gates and verify actual target state. Those OIDC/durable-execution controls are **not mandatory for a short authorized read-only invocation**.
6. Distinguish local simulation, configured resources, model-call result and actual live deployment proof.

Gateway, Browser, Memory and other components are optional, not a starter
checklist. This guide owns the reusable selection and procedures below;
installed configuration, account/provider choices and project evidence remain
with their owners. It is not an exhaustive API reference or deployment mandate.

## Select a primitive only for a demonstrated need

| Need | Candidate primitive | Additional boundary to establish |
| --- | --- | --- |
| A configuration-defined agent loop | Harness | Effective tools, execution limits, model and managed runtime effects |
| Custom orchestration/dependencies | Runtime | Application-owned code, packaging and deployment evidence |
| Conversation knowledge beyond one interaction | Memory | Retention, actor/session scope, sensitive-data handling and cost |
| Expose existing APIs/functions as agent tools | Gateway | Exact tool contract, downstream authorization and network/source access |
| Inbound/outbound agent authentication | Identity | Caller versus workload identity, credentials and token boundaries |
| Managed web interaction | Browser | Allowed sites/actions, data exposure and session lifecycle |
| Managed code execution | Code Interpreter | Inputs, isolation, data/network/tool scope and cleanup |
| Diagnose/audit the execution path | Observability | Trace access, payload redaction, logging dependencies and retention |

AgentCore services can be used independently. An agent experiment does not
require all of them. Policy, Payments and other capabilities require their
own demonstrated need, available service support and applicable approvals;
do not enable them merely because they appear in a service catalog.
Each added primitive changes IAM, cost, evidence and lifecycle scope.

## Harness: preparation versus managed execution

Harness supplies a managed Strands-powered loop as an abstraction within
Runtime. Configuration can express the model/instructions, tools, memory,
skills, execution limits and environment. Runtime by itself hosts code; its
presence does not make application orchestration or authorization automatic.

Local files/CLI validation can prepare a configuration and expected tool
contract. They do not prove a resource was created, an invocation ran, a trace
was available or a deployed endpoint behaved correctly. Resource creation,
invocation, configuration/version/endpoint changes, trace retrieval and
deletion have their own access and effect boundaries. A source-only task
stops before those operations.

### Bounded Harness lifecycle

1. State the learning question and exact observable result, not "try every
   service". Select synthetic data and one deterministic no-op/read-only tool.
2. Prove accepted and denied argument/authorization behavior outside the model.
   Use existing focused checks; do not invent a framework for the experiment.
3. Resolve the approved account/Region, resource name/purpose/revision,
   actual tool allowlist, maximum model calls/loop/time/spend and evidence/
   retention disposition. Enumerate default/built-in capabilities too:
   one read-only custom tool does not prove shell/filesystem tools are absent.
4. If cloud setup is within the approved envelope, create one bounded resource
   through the supported project route. Save the resource/version/configuration
   and returned execution identity. Do not infer creation from local files.
5. Make one approved known-input invocation. Inspect model/tool events,
   validated arguments, tool result and final response against the expectation.
   Record failures and uncertainty without blind invocation replay.
6. When a second experiment is needed and authorized, change one relevant
   configuration value, capture its version and compare the same evidence.
   Do not add unrelated Memory/Browser/Gateway/network/container scope.
7. Record actual resource and cost state. Delete disposable resources only
   through the authorized lifecycle, verify disposition and preserve required
   evidence. One workflow may already authorize these steps; milestones are
   not routine new-GO gates.

Keep shell, arbitrary filesystem, Browser, Code Interpreter, broad Gateway
and remote MCP access out of the experiment unless the actual requirement
and tool boundary justify them. Inspect the effective configuration rather
than assuming a provider's defaults are safe or unchanged.

### Trace and cost checklist

Keep request/session/trace identity, model/configuration version, tool calls,
validated inputs, results, final outcome, durations and any changed resources.
Observe the supported logging/permission prerequisites; a successful response
without the required trace is not the promised trace acceptance.
Telemetry may contain sensitive payloads and must follow project retention.

Budget model tokens and the actual Runtime/Memory/Browser/Code Interpreter/
Gateway/storage/observability capabilities used. A locally running client can
call a paid provider. Do not infer zero cost from "local", "serverless" or a
source note about no separate Harness fee. Prices, free tiers, quotas,
supported providers/Regions, managed-memory defaults and service status must
be checked for the current task; this page fixes no numeric rate or model list.

## Strands: own the loop only when the task needs it

Strands is an agent SDK, not a requirement to use AgentCore hosting. Its loop
requests a model response, executes selected allowed tools, returns their
results to context and continues until a response/stop condition. Authorization,
target selection, tool argument validation and mutation permission remain
deterministic boundaries outside that model choice.

For a local learning path:

1. Define explicit instructions and one known expected synthetic result.
2. Supply one deterministic no-op/read-only tool with validated arguments.
3. Record requested tool name/arguments, authorization/validation decision,
   actual result and final model response.
4. Exercise a malformed/unauthorized request with the smallest meaningful
   existing proof; retain the denial rather than merely claiming an allowlist.
5. State whether the model is an approved remote provider or local test double.
   Local SDK execution is not proof of offline/no-cost behavior.
6. Stop before deployment unless hosting is separately inside the goal.

Choose code ownership when custom orchestration, middleware/dependencies,
portability outside Harness or explicit source ownership is the actual
requirement. Skip Strands when a deterministic script, simple documentation
lookup/API call or sufficient managed configuration answers the question.
Do not let a framework choice expand the dependency or operating budget.

### Export a working Harness only for a reason

At the documentation check date, AWS's export guide describes editable
Python/Strands source. Check current formats and CLI support before using it;
future-framework statements are not promises this guide can enforce.

Preserve the original configuration/version and export into the project-owned
source/review path. Review generated code and export notes for model/API-key
references, tools, memory, skills, limits, truncation, mounts, authorizers and
network permissions. Re-establish denied-tool/input and resource boundaries;
generation is not proof of semantic or security equivalence. Version and
validate the result like other application code before any authorized deploy.
Retain the managed path until the replacement is accepted.

If the configuration already satisfies the task, keep it; exporting is not a
mandatory graduation step. Installing an SDK/plugin, invoking a model and
deploying Runtime are distinct effects, none authorized by reading a guide.

## Related

- [Shared Core](../CORE.md)
- [Proportional testing](../TESTING.md)
- [Evidence lifecycle](../KNOWLEDGE.md)
- [AWS identity, cost and source boundaries](../AWS.md)
- [Toolkit selection and optional setup](TOOLKIT.md)

## Citations

- [AgentCore Harness vs Runtime](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/harness-vs-runtime.html)
- [AgentCore overview](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/what-is-bedrock-agentcore.html)
- [Strands agent loop](https://strandsagents.com/latest/documentation/docs/user-guide/concepts/agents/agent-loop/)
- [Harness operations, traces and cost controls](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/harness-operations.html)
- [Harness export capabilities and review notes](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/harness-export.html)
- [Strands SDK source](https://github.com/strands-agents/sdk-python)
- [Pinned source service selection](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/aws-agent/BEDROCK_AGENTCORE.md)
- [Pinned source Harness procedure](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/aws-agent/HARNESS.md)
- [Pinned source Strands procedure](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/aws-agent/STRANDS.md)
