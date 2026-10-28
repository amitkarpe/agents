---
type: Policy
title: AWS Identity, Sources and Operational Evidence
description: Select an authorized AWS execution identity and preserve private-source, lifecycle, cost and recovery evidence.
status: candidate
confidence: high
scope: Portable AWS operating guidance; project permissions and local configuration remain authoritative
last_verified: 2026-10-28
review_after: 2027-01-28
tags: [aws, identity, authentication, networking, lifecycle, evidence]
---

# AWS Identity, Sources and Operational Evidence

Use this for AWS work, alongside the owning project and [Core](CORE.md).
Documentation access, authenticated inspection, mutation and host setup are
different operations. This policy grants none of them. Examples below are
templates, not evidence that a profile, tool, endpoint or resource exists.
Primary documentation was checked on the verification date; no account calls
or runtime validation were performed to publish this guide.

## Select the smallest authorized route

| Need | Route | Required distinction |
| --- | --- | --- |
| Service/API documentation | Official documentation or a knowledge-only tool | Documentation is not account access or live resource proof |
| One bounded inspection, transfer or diagnosis | Existing approved CLI/API route | Explicit identity, target and source/destination; a transfer may write data |
| Related calls or auditable batch | Existing approved API scripting surface | Use exact profile selection and preserve its actual provider receipt |
| Repeatable build, validate, scan, promote or recovery | Versioned project automation or AWS-native workflow | Do not leave the operating implementation in chat or a temporary evidence script |
| Toolkit/plugin/bootstrap | Separately scoped local setup | See [Toolkit](aws/TOOLKIT.md); capability installation is not AWS permission |

Reuse a matching executable skill or project wrapper when it already owns the
procedure. Do not copy its implementation into another runner. A short approved
read need not acquire a new CI pipeline; durable mutations follow the existing
[AWS-owned control](aws/OIDC.md) pattern where applicable.

## Establish effective identity and role boundaries

Before relying on account results, verify the approved profile/credential
source, account, assumed role and Region. Environment credentials, a selected
profile, instance credentials and a proxy's default profile can differ.
Inspect configuration through safe metadata/presence checks, not credential
dumps. Never silently substitute a fallback when a selected profile is invalid.

An authorized identity read can be recorded without logging credentials:

```bash
aws --profile '<PROFILE>' --region '<REGION>' sts get-caller-identity
```

Compare the account and role to the owning task's expected values; STS success
alone does not prove permission for the next operation. Recheck after login,
role assumption, authentication/connection failure or an identity change.
For a sensitive action, assert the expected account/role/Region and exact target
in the same execution path as the operation. Do not switch accounts, roles,
profiles, Regions or tools to evade an authorization denial.

Keep distinct:

- the CI runner role and the assumed workload/control role;
- an SSM Automation execution role and the managed node's instance-profile
  role used by commands running there;
- `iam:PassRole` permission and the passed role's trust/permission policies.

Passing a role does not make it assumable by every service or give the caller
its permissions. Scope PassRole to approved roles/services under the project;
this guide provides no broad IAM policy or approval to attach one.

## Expired authentication: recover the same route

When the approved task permits renewing its configured IAM Identity Center
session, use that exact profile's configured login flow:

```bash
aws sso login --profile '<PROFILE>'
aws --profile '<PROFILE>' --region '<REGION>' sts get-caller-identity
```

Human password/MFA interaction stays with the human. Never request, enter,
copy or publish those secrets. Do not change start URLs, role/account mappings,
device-code/browser flow or credential files to force success. On failed login
or mismatched identity, preserve the error category and stop that account
action; do not loop, clear unrelated caches or change profiles speculatively.
Authentication renewal does not expand the task's permissions.

If a connector expires during a durable operation, retain its execution ID and
reconcile that same execution after access is restored. An unknown reply is
not proof of failure and is not permission to resubmit; see [OIDC](aws/OIDC.md).
One failing connection is not proof that another approved session/tool is
broken. Preserve healthy routes; do not restart all configured providers.

## Private source and network preflight

Use the environment's actual network and artifact policy, not a DEV/PROD
label inferred from a directory. In restricted/private-only work, prefer:

1. the project's approved internal artifact/package repository;
2. approved private service endpoints or PrivateLink;
3. verified preloaded/staged artifacts;
4. public egress only when that exception is actually authorized.

Do not add NAT, expose a service, substitute a public image or disable TLS
verification to make a proof pass. Check from the execution host, not merely
the controller: DNS resolution, TLS, endpoint routing/security groups,
authentication/permission, object metadata and the required artifact itself.
Reachability does not establish authorization. Preserve the first failed layer
and use exact OS/architecture/package inputs; a local example is not an
approved registry inventory.

For an instance-only launch into an already-approved private subnet, verify
the subnet and public-IP mapping in the launch request and confirm the
resulting instance has no public IP. Broaden the network preflight only when
the change touches routes, NAT/gateways, endpoints, peering, load-balancer
exposure or another concrete network boundary.

For private API/SSM/CIS work:

- resolve which service endpoints are needed in this Region and agent version;
  an old endpoint checklist is not authority to create every endpoint;
- check private DNS, endpoint policy, endpoint security-group access and the
  workload's own egress controls; an endpoint resource merely existing is not
  host-side reachability proof;
- inspect available subnet IPs before adding interface endpoints: each
  selected subnet needs capacity for endpoint network interfaces;
- distinguish `InsufficientFreeAddressesInSubnet`, DNS timeout, TLS error,
  missing credentials and authorization denial;
- use approved in-Region S3 staging when the workload cannot fetch a public
  input; verify bucket/endpoint policy and object access rather than assuming
  that private networking automatically supplies permission.

Detailed task preflights are in [SSM](aws/SSM.md) and
[Inspector CIS](aws/INSPECTOR_CIS.md). Generic package/registry installation
procedures remain with their current owners; no speculative topic is required.

## Lifecycle, naming, tags and resource records

Choose the project's naming and tag schema before creation. Include useful
human identity, owner, project, environment, purpose, revision, creation time,
retention/expiry and cleanup disposition wherever the service supports them.
Do not encode a transient assistant/model identity as durable ownership or
approval. Unsupported tags belong in the existing project record, not a false
claim that every child inherited them.

The source notes used conflicting `TTL`/`ttl` keys and date formats.
Canonical guidance does not select a universal spelling, threshold or retention
duration. Reuse the owning project's schema and resolve ambiguity before the
affected creation. Expiry is a review signal, never automatic deletion authority.

For indirect/child resources, record a tagging gap when propagation is incomplete:

| Record | Preserve |
| --- | --- |
| Parent action and expected children | What can remain after the parent succeeds or fails |
| Propagation support and observed tags | What is inherited, unsupported or missing |
| Follow-up | Exact owner, approved tagging action and retention/review date |
| Recovery | How resources and evidence remain identifiable if the action partially completes |

For assets important to cost, security, lineage or rollback, use the existing
simple project registry/history rather than inventing a second inventory.
Useful fields are timestamp/action, type/ID/name, project/workload/owner,
environment/purpose, revision/build source, creation/expiry/disposition,
parent/source, owning Issue and evidence. Lightweight short-lived resources
may already be adequately recorded by the owning workflow; avoid ceremonial
duplicate files. CloudTrail is valuable but not a substitute for the project's
semantic build/promotion record. [Images](aws/IMAGES.md) distinguishes an AMI
registry from a mutable current-image pointer.

Report resources with type, identity, human name, relevant revision and
retention state, not bare opaque IDs. Public reports use sanitized aliases;
exact account/resource identities and raw receipts stay in approved evidence.

## Cost and high-risk changes

Before potentially costly work, estimate with Region, unit prices, quantities,
duration, storage, transfer and dependent services. For a cluster, a useful
method is control-plane rate × hours + node rate × node count × hours +
storage/transfer/observability. State assumptions and use current prices;
source examples and monthly hours are not a quote.

Compare against the task's actual spending limits. There is no universal
approval amount or override phrase in this policy. Account for resources left
running during investigation and for separately metered model/service use.
Bound debug retention with an owner, reason and review/expiry; preserve
required evidence before the separately authorized cleanup.

Broad administration, public data exposure, public management access, IAM,
network, encryption and production changes retain project safety gates.
Identify the exact blocked action, risk and safer option. Do not infer an
exception from authentication or from a tool offering the operation.

## Task routes

- [Inspector/CIS readiness and diagnosis](aws/INSPECTOR_CIS.md)
- [SSM execution, recovery and NoReboot](aws/SSM.md)
- [Images, snapshots, keys, lineage and consumption](aws/IMAGES.md)
- [Toolkit and knowledge-versus-execution routing](aws/TOOLKIT.md)
- [AgentCore, Harness and Strands](aws/AGENTCORE.md)
- [Terraform ownership and drift](TERRAFORM.md)

## Citations

- [Pinned public source learning](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/AWS.md) — mixed local values and historical inventory are not promoted.
- [AWS CLI credential and configuration precedence](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
- [IAM Identity Center CLI login](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html)
- [Passing roles to AWS services](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_passrole.html)
- [Systems Manager VPC endpoints](https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-create-vpc.html)
- [AWS cost estimation](https://calculator.aws/)
