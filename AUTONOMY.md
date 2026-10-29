---
type: Policy
title: 1000X Single-Agent Autonomy
description: One owner-selected agent owns development, AWS DEV execution and repository operations without routine human or second-agent approval.
status: reviewed
scope: Opt-in owner-directed DEV and repository autonomy; production controlled by recorded scope
confidence: high
review_after: 2027-04-29
tags: [agents, autonomy, single-writer, dev, aws, no-handoff]
---

# 1000X Single-Agent Autonomy

**ONE AGENT. ONE WRITER. NO G -> X HANDOFF. NO ROUTINE APPROVAL.**

The owner-selected agent decides, implements, tests, fixes, operates and closes
out work end to end. Its standing authority comes from the adopting project's
`AGENTS.md`, this policy, and the owner's current instructions. It does **not**
need a new GO, Amit review, G approval, Codex/Kiro review or another agent's
permission for each already-authorized milestone. Automated findings are input
to fix, not a new reviewer veto unless an actual platform/governing rule
requires review.

## Scope and precedence

An owning repository must explicitly adopt this policy and identify the
**exact authorized environment or account**. This file is public-safe and
does not enumerate private accounts or credentials; the adopting repository
does. For the three owner-selected V2 repositories, that adoption grants
**standing, end-to-end DEV authority**, not just source-code authority.

Current owner direction and exact environment binding control over historical
repository text that said "repository-only", "no live AWS", "manual G handoff",
or "ask again". Historical records and NOT_RUN test claims remain facts; they
are not standing vetoes on newly authorized DEV work.

This policy does not create technical IAM permissions, install a cloud
connector, start an agent, disable a guardrail or override legal,
organizational, provider-managed, account or branch protection controls.
Verify effective credentials and permissions; never pretend unavailable access.

## Full DEV execution — standing authority

**For the exact DEV account named by an adopting V2 repository, the designated
agent has standing owner authorization to run normal DEV work without
case-by-case human approval.** This includes:

- AWS read, inventory, troubleshoot, provision, configure, update and operate
  DEV services: EC2, AMIs, VPC/subnets/security groups, endpoints, S3, EFS,
  CloudWatch, SSM Run Command/Automation/Documents/Patch Manager, CodeBuild,
  CodePipeline, CloudFormation, EC2 Image Builder, Terraform plans/applies
  and other task-relevant DEV resources.
- Create, update and attach DEV IAM roles, policies, permissions, instance
  profiles and trust relationships; use existing approved SSO/STS identities
  and account-specific IAM naming rules. The agent may create the necessary
  compliant role or policy itself; no second GO solely for IAM creation.
- Launch/stop/start DEV compute, run approved diagnostics and SSM documents,
  modify DEV networking as required for the task, perform bounded canaries,
  and read back actual provider state.
- Configure project-owned DEV GitHub/GitLab CI/CD, repository files,
  branches, Issues/PRs/MRs, tags, workflows and releases; choose, fix and
  self-merge changes when platform requirements allow.
- Use authorized local files, tools and workspaces needed to implement and
  operate the project. No new permission interview for ordinary workspace
  reads/writes or troubleshooting.

**Required operational discipline, not a request for approval:** verify live
`sts get-caller-identity` account and role, exact region/resource/target,
plan impact and likely costs; use minimal exposure and least privilege
compatible with the task; preserve secrets and evidence; run appropriate
checks; reconcile provider responses and record actual results. Never
silently switch to another account. Existing mandatory IAM naming rules and
provider constraints remain active. Expense thresholds, managed policies
and technical denies are not bypassed.

## GitHub, GitLab, local files and decisions

Within the owning/adopted project and the owner's existing accessible
development workspaces, the sole agent may create/edit/delete source files,
manage branches/Issues/PRs/MRs, push, merge, tag and configure ordinary DEV
pipelines **without requesting human review**. It may use the existing local
filesystem and tooling for project work, including creating and modifying
project directories or generated output.

The agent must not impersonate a reviewer, turn off required checks or
branch protections, exfiltrate secrets, delete unrelated personal/private
files, erase dirty or active work, or destructively remove a repository,
persistent state, backup or audit record without **specific recorded scope**
in the owner's Issue, PR, roadmap, spec or explicit instruction. Such an
existing record is sufficient authorization; it does not need a repeated GO.
For an irreversible action, verify exact targets and a recovery/rollback
strategy where feasible. Respect ownership of other writers/sessions.

## Production — scoped, not a standing blank cheque

Production is **not** covered by the DEV account-wide standing grant.
The agent may carry out a **non-destructive production operation** when
an owner-authored or owner-approved Issue, PR, roadmap, specification or
explicit instruction identifies the intended environment, objective and
resource scope; that durable instruction is authorization, without a
second conversational GO. This may include authorized diagnostic reads,
troubleshooting, SSM observation and **creating a production EC2 instance**
when that creation is expressly within the recorded scope.

For production deletion, replacement, fleet patching/reboot, persistent
permission or security-policy weakening, data loss, large-scale changes or
other irreversible/destructive effects, require explicit **action-specific**
owner authorization and applicable change-control/security approvals.
A vague roadmap title or unreviewed agent-authored issue is not a substitute.
If the PROD environment/owner/target is unclear, stop that operation; keep
unrelated DEV work moving.

## Independent work and merge

1. Verify the repository and designated sole writer, source HEAD, existing
   issues/PRs and the exact AWS identity before cloud mutations.
2. Choose the next useful task, plan as deeply as the actual risk demands,
   implement it and run meaningful validation.
3. Fix CI, security and Codex findings. Distinguish actual failures from
   policy/tooling limitations; don't invent test PASS.
4. Merge eligible source PRs without another routine human/agent vote using
   the ordinary platform path. If GitHub/GitLab enforces a review/check,
   comply or report the real gate; do not bypass.
5. Confirm source/provider readback and document evidence. Continue other
   authorized milestones without repeated handoffs.

`UNKNOWN` is not `FAIL` or `SUCCESS`: reconcile before trying another
state-changing action. Do not build duplicate workers, blindly repeat SSM
commands, or create a second background daemon merely for autonomy.
Existing sessions may continue only while their actual runtime is active;
this policy is not an unattended scheduler.

## Adopted V2 repositories

- **Patching V2:** full standing DEV AWS/SSM/canary and source authority
  in its explicitly bound DEV account.
- **Trustdev V2:** full standing DEV AWS/consumer troubleshooting and
  source authority in that exact DEV account; retain cross-project ownership.
- **AMI Factory V2:** full standing DEV AWS/IAM/Terraform/Image Builder,
  GitLab and source authority in its explicitly bound DEV account.

## Related

- [Goals and Delegation](GOALS.md)
- [Git Workflow](GIT.md)
- [Shared Core](CORE.md)
- [Connector Safety](SAFETY.md)

## Citations

- [Patching V2 adopting instructions](https://github.com/amitkarpe/patching-v2/blob/main/AGENTS.md)
- [Trustdev V2 adopting instructions](https://github.com/amitkarpe/trustdev-v2/blob/main/AGENTS.md)
- [AMI Factory V2 adopting instructions](https://github.com/amitkarpe/ami-factory-v2/blob/main/AGENTS.md)
