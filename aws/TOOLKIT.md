---
type: Playbook
title: AWS Toolkit, Knowledge and Execution Routing
description: Choose a narrow AWS knowledge/plugin/MCP route and distinguish setup, authenticated execution and durable project automation.
status: candidate
confidence: high
scope: Portable toolkit selection and approved setup procedure; no installed-tool or account-access claim
last_verified: 2026-10-28
review_after: 2027-01-28
tags: [aws, toolkit, mcp, authentication, plugins, terraform]
---

# AWS Toolkit, Knowledge and Execution Routing

Apply [AWS identity and access rules](../AWS.md). A visible server, installed
skill, subscription or plugin is capability metadata, not permission or proof
of a live account action. Keep documentation retrieval separate from API
execution and from agent/host configuration changes.

## Choose a surface by the task

| Task | Candidate | Boundary |
| --- | --- | --- |
| Find current AWS service/API guidance | Official documentation, AWS Knowledge or knowledge tools | Does not prove account identity or resource state |
| General AWS coding guidance | Agent Toolkit's aws-core plugin | Add only when supported and useful; not mandatory per-task bootstrap |
| Bedrock/AgentCore development | aws-agents specialist plugin | See [AgentCore](AGENTCORE.md); installed skills do not approve inference |
| Data lake/analytics/ETL | aws-data-analytics | Select for this subject rather than load every plugin globally |
| DevOps/Security Agent task | aws-agents-for-devsecops | Confirm exact service/task, supported control/workload Regions and scope before enabling |
| Terraform provider/module knowledge | Official HashiCorp Terraform MCP | Project-owned Terraform remains the write path |
| CloudFormation/CDK-specific assistance | Applicable AWS IaC tooling | Not a replacement Terraform apply controller |
| Account inspection/API batch | Existing approved AWS CLI or authenticated MCP route | Exact target/profile and actual returned evidence |
| Repeatable production operation | Versioned repository/AWS-native execution | An interactive MCP result does not prove a CI/OIDC execution path |

The official Agent Toolkit repository is the starting point for supported
equivalents to older AWS Labs plugins/servers. Do not automatically replace a
working configured tool, and do not assume every old specialist has an exact
successor. Verify the selected capability and compatibility before migration.
Avoid overlapping global servers that expose redundant tools and ambiguous
credentials; the goal is the smallest useful tool set, not maximum discovery.

AWS's plugin documentation lists Codex/Claude plugin support and direct MCP
connection for Kiro. Recheck current client support; a dated CLI floor or tool
count is not proof of the installed host's features.

## Knowledge is not authenticated execution

Documentation/knowledge search can be available without account credentials.
It answers what a service documents, not whether an IAM principal can use it.
AWS MCP API-backed tools and script execution use authenticated permission and
can have side effects. A sandbox or audit log does not create task authority.

Discover only the required tool schema and distinguish:

1. configured server/client;
2. callable tool in the actual selected session;
3. expected effective account/role/Region;
4. permission for the named action/resource;
5. observed result and durable evidence.

Do not infer these layers from another agent's healthy connection. Do not
restart multiple profiles or demand an unrelated OAuth login when an
independent approved SigV4 route is already healthy. Conversely, a successful
knowledge lookup must never be reported as an authenticated AWS probe.

## OAuth, SigV4 and multi-profile requests

| Route | Identity behavior | Use deliberately |
| --- | --- | --- |
| Direct OAuth connection | Session is associated with its authenticated role; multi-profile switching is not supported | Follow the configured login route and its actual account authorization |
| AWS MCP Proxy with SigV4 | Configured profiles can be selected per authenticated request through the exposed aws_profile parameter | Name the approved profile explicitly and verify returned identity |
| Project CLI/API workflow | Uses its effective configured credential chain | Apply the same exact identity/permission checks; not a denial-evasion fallback |

The proxy's first/default profile is not necessarily the task's intended
account. An invalid profile is a selection error to reconcile, not permission
to choose another one until the call works. Proxy-added profile switching is
specific to supported AWS MCP tools; do not assume the parameter exists on
every MCP server or that forwarding a label changes downstream identity.

Before cross-account calls, resolve the approved profile/role mapping, check
the exact tool's schema, select the intended profile and verify STS/account
context. After role/authentication changes, recheck. Credentials, profile
contents and private account registers remain local/project-owned.

## Optional setup procedure — only within a setup authorization

1. Inspect the selected client, configuration and current working connections.
   Discover installed CLI version/help; do not infer support from an old guide.
2. Save exact preimages, link ownership and a scoped restore path before
   configuration edits. Identify the one selected client/agent; do not silently
   enable all discovered agents.
3. Review current official setup choices. AWS documents an interactive
   `aws configure agent-toolkit` route; use the supported operation only when
   that host task is approved. Avoid unattended accept-all flags that widen
   the selected surface.
4. Do not overwrite or duplicate a healthy existing execution connection.
   Resolve tool-name/auth conflicts before replacing a server.
5. Check generated configuration and source ownership; keep auth/runtime
   material in the native owner. Skills stay in their executable package
   owner, not mirrored as documentation source.
6. When separately allowed, use one bounded task-relevant read to distinguish
   installation from actual callability/identity. A printed list or automatic
   discovery does not prove activation. Retain rollback and report the exact
   installed scope; no provider-wide success claim.

The commands here describe an optional procedure; publishing this guide runs
no wizard, login, refresh, model request or AWS call.

## Terraform and AWS-native IaC

For Terraform knowledge/discovery, use current official provider/module/Registry
information, then edit project-owned `.tf`/`.hcl` and use its existing
format/validate/plan/review/apply path. Keep destructive/remote-operation
capabilities disabled unless explicitly needed and approved. A knowledge
server must not become an alternative production apply controller.

AWS IaC tooling is selected for a concrete CloudFormation/CDK/validation
need, not because its name resembles Terraform MCP. Reuse existing automation
and approval gates. For either stack, an agent's proposed patch is not a
deployed resource; [Terraform](../TERRAFORM.md) and [OIDC](OIDC.md) retain
state and durable-execution boundaries.

## Preserve the local remainder

Client aliases, configured server names, profile allowlists, binary/cache paths,
actual exposed schemas/tool counts, bootstrap status, agent defaults and
account entitlements stay local. The source's September/October observations
are dated provenance, not assertions that a host is installed or uninstalled.
Do not generalize a fixed model/Region list or automatic account discovery
from a personal environment template.

## Citations

- [Pinned source selection/setup and failure boundaries](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/aws-agent/AGENT_TOOLKIT.md)
- [Official Agent Toolkit](https://github.com/aws/agent-toolkit-for-aws)
- [AWS Toolkit components](https://docs.aws.amazon.com/agent-toolkit/latest/userguide/what-is-agent-toolkit.html)
- [Plugins, clients and specialist families](https://docs.aws.amazon.com/agent-toolkit/latest/userguide/plugins.html)
- [AWS CLI setup wizard](https://docs.aws.amazon.com/cli/latest/reference/configure/agent-toolkit.html)
- [AWS MCP authentication setup](https://docs.aws.amazon.com/agent-toolkit/latest/userguide/getting-started-aws-mcp-server.html)
- [SigV4 multi-profile behavior](https://docs.aws.amazon.com/agent-toolkit/latest/userguide/multi-account-access.html)
- [HashiCorp Terraform MCP](https://developer.hashicorp.com/terraform/mcp-server)
- [AWS IaC MCP](https://awslabs.github.io/mcp/servers/aws-iac-mcp-server)
