---
type: Policy
title: Terraform State and Drift Decisions
description: Verify Terraform's target and ownership before changing state or reconciling drift.
status: reviewed
scope: Reusable Terraform change and drift guidance
confidence: high
timestamp: 2026-10-21T21:48:34+08:00
review_after: 2027-04-21
tags: [agents, terraform, state, drift, infrastructure]
---

# Terraform State and Drift Decisions

The owning repository defines the intended infrastructure and approval gates;
this guide does not grant permission to change cloud resources or state. Use
[Shared Agent Core](CORE.md) for source authority and
[Testing and Validation](TESTING.md) for proportionate checks.

## Establish the exact target

Before planning or changing anything, verify the selected workspace and
environment, backend and state location, variable files and other input
sources, plus the target account and Region where applicable. Confirm the
effective identity through the owning project's approved local routing. Do
not infer backend, state, credentials or target from a directory name, default
workspace, remembered command or prior output. Stop when the target or input
sources cannot be established.

## Decide ownership before correcting drift

Compare declared configuration, Terraform state and live resources read-only.
Identify whether the difference is intended, accidental or outside this
repository's ownership. Record the ownership decision before changing the
baseline: adopt an existing resource through a reviewed import, correct the
declared configuration, or explicitly leave the resource unmanaged. Do not
silently make a manual cloud change or rewrite state merely to obtain a clean
plan.

For an approved correction, make the durable change in the owning IaC source
and use its reviewed state-change process. An exceptional manual cloud action
requires explicit break-glass approval and a recorded action; reconcile the
IaC source and state afterward, then verify the live result. For AWS-controlled
mutations, follow the [GitHub OIDC and AWS-Owned Control
playbook](aws/OIDC.md); its bounded
execution and uncertain-retry gates remain there.

## Concrete drift warnings during diagnosis

Requests to "sync scripts to the account", make a manual endpoint/security-group
fix, or "make it work now, Terraform later" can turn accidental drift into an
unreviewed baseline. Establish intended ownership before adopting observed
state. A bounded proof instance or test image does not authorize persistent
changes to shared IAM, networking, endpoints or account controls.

Inspect live state, compare configuration/state/design, classify the fault,
make the durable IaC correction, and verify after its reviewed apply.
Use [image lineage and consumption](aws/IMAGES.md) for image-specific evidence;
provider/worker role names do not grant any of these writes.
