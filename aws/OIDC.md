---
type: Playbook
title: GitHub OIDC and AWS-Owned Control
description: Use GitHub OIDC for bounded AWS control while keeping long execution in AWS-owned services and preserving explicit identity, scope, and readback gates.
status: reviewed
scope: GitHub Actions, OIDC, and AWS control automation
confidence: high
timestamp: 2026-09-22T16:18:35+08:00
last_verified: 2026-09-22
review_after: 2026-12-22
tags: [github, oidc, aws, automation, codebuild, ssm]
---

# GitHub OIDC and AWS-Owned Control
> **Ownership:** This specialist guide documents one bounded topic. The
> canonical [Core](../AGENTS.md), [Goals](../GOALS.md),
> [Context](../CONTEXT.md) and [Safety](../SAFETY.md)
> rules govern reusable authority and evidence. Project rules and local
> provider/host configuration still take precedence. A documented command or
> reference is not proof of current runtime support.


Use this pattern when GitHub should authorize a bounded AWS control action without making an interactive browser, MCP, SSO, or runner session responsible for long execution.

## Core separation

Keep five concerns separate:

1. **Repository access** — GitHub App or normal GitHub permissions.
2. **Workflow definition** — GitHub Actions.
3. **Execution substrate** — GitHub-hosted runner, CodeBuild-hosted runner, or another reviewed runner.
4. **AWS control identity** — GitHub OIDC to a bounded IAM role.
5. **Long execution** — an AWS-owned service such as SSM Automation, CodeBuild, CodePipeline, Step Functions, Image Builder, or another appropriate native service.

The runner service role is not the workload/control role.

## Preferred office control path

For durable office AWS automation, prefer:

`GitHub request -> GitHub Actions -> runner -> GitHub OIDC -> bounded AWS role -> short control action -> AWS-owned execution`

A CodeBuild-hosted GitHub Actions runner is useful when AWS-local execution, VPC access, runner scheduling, or GitHub-hosted-runner constraints justify it. Do not make it universal when a normal GitHub-hosted runner is sufficient.

The GitHub job should normally remain short:

`authenticate -> verify repo/ref -> verify account -> verify Region -> verify exact target -> start one bounded AWS operation -> persist execution ID -> exit`

## Durable execution checkpoint

Before the short controller exits, persist enough state for another session or worker to resume safely:

- request or plan digest;
- account/environment and Region;
- exact target resource;
- execution service;
- execution ID;
- last observed status;
- provider/readback evidence pointer.

Examples include:

- SSM Automation execution ID;
- CodeBuild build ID;
- Step Functions execution ARN;
- CodePipeline execution ID;
- CloudFormation stack or change-set identifier.

Before retrying a mutation, read the existing execution state first. Never blindly start a duplicate mutation merely because a ChatGPT, MCP, SSO, runner, or browser session ended.

## Fail-closed mutation gate

Before a write, verify at minimum:

- expected repository and ref;
- expected AWS account;
- expected Region;
- exact target resource;
- expected change shape;
- no unrelated IAM, network, compute, or replacement change;
- provider/readback path exists.

For Terraform-controlled changes prefer:

`import/read live state -> plan -> machine gate -> review gate when required -> apply exact reviewed plan -> provider/Terraform readback`

### Image-build requests

For Packer or AMI/Image Builder work, also verify the source image identity,
target account and Region, intended build network, expected output artifacts,
and cleanup/retention boundaries. Treat temporary build resources as stateful
and cost-bearing until verified removed or explicitly retained. Capture the
resulting image identity and validation evidence; process exit alone does not
prove a successful build or resource cleanup.

## Interactive tools versus durable control

AWS MCP, CLI, SSO, AgentCore Harness, or another interactive operator surface may be appropriate for:

- discovery;
- read-only inspection;
- short troubleshooting;
- preparing a bounded request;
- reading execution status.

They should not be the durable office mutation dependency when their credentials can expire mid-work.

A useful separation is:

`operator surface -> detect/explain/prepare -> durable approved request -> GitHub/OIDC controller -> AWS-owned execution -> provider readback`

Connector expiry is a credential event, not a planning reset:

`checkpoint in GitHub -> continue repository-only work -> reconnect only when live AWS is the blocker -> verify identity -> resume from execution state`

## SSM does not imply EC2

Do not create one EC2 instance per account merely to gain control.

For compliance and remediation prefer:

`native AWS API -> AWS-managed SSM Automation -> custom SSM Automation -> Lambda only when justified`

SSM Automation can invoke AWS APIs without an EC2 managed node.

Use EC2 plus SSM only when a real host or VPC-local requirement exists, such as:

- private endpoints;
- internal DNS;
- local binaries;
- host patching;
- host-level validation.

## Multi-account default

Prefer one durable controller and the same narrow target-role contract in each account:

`GitHub OIDC controller -> bounded controller role -> STS AssumeRole -> target role -> AWS-owned execution`

Re-verify target identity after every role assumption.

Do not require one runner or one EC2 instance per account unless network locality requires it.

## Troubleshooting order

Use this order:

1. runner assigned?
2. workflow step reached?
3. OIDC token exchange reached?
4. STS caller identity correct?
5. target account/Region correct?
6. AWS API permitted?
7. execution ID created?
8. AWS-owned execution succeeded?
9. provider readback correct?

Do not classify `RUNNER_NOT_ASSIGNED` as an OIDC or IAM failure.

## Reuse rule

Generalize the controller substrate; keep workload-specific behavior in repository-owned configuration; keep permissions bounded.

Avoid creating a new broad role, runner, or workflow for every workload when the execution shape is materially the same.

## Citations

- https://docs.aws.amazon.com/codebuild/latest/userguide/action-runner-overview.html
- https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp_oidc.html
- https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-automation.html
- https://github.com/amitkarpe/ami-factory
- https://github.com/amitkarpe/nextflow-offline
