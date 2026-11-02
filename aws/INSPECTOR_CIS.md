---
type: Playbook
title: Inspector CIS Readiness, Targeting and Evidence
description: Prepare a precise CIS scan, diagnose unusable results and preserve complete security evidence without inventing promotion or deletion authority.
status: candidate
confidence: high
scope: Amazon Inspector CIS on supported EC2 systems; project-specific compliance authority remains separate
last_verified: 2026-10-28
review_after: 2027-01-28
tags: [aws, inspector, cis, ssm, security, evidence]
---

# Inspector CIS Readiness, Targeting and Evidence

Use [AWS identity/source gates](../AWS.md) first. This runbook does not enable
scanning, attach policies, change metadata options or approve a billable scan.
Package-vulnerability coverage and a healthy SSM node do not establish CIS
readiness. Verify the current supported operating system, architecture,
benchmark and Region; do not extrapolate one platform's control count.

## Readiness checklist

| Layer | Read-only evidence | When it fails |
| --- | --- | --- |
| Target and account | Approved profile/account/Region, exact intended instances and scan owner | Resolve identity/ownership before creating a scan |
| EC2 scanning/platform | Applicable Inspector EC2 scanning enabled; supported CIS platform | A package scan or stale plugin error is not proof of current CIS support |
| SSM | Node listed as managed/online, healthy agent, current Inspector SSM plugin/association | Diagnose registration, agent and distribution evidence |
| Instance role | SSM management and CIS session permissions | Check actual attached/effective permissions, including boundaries and denies |
| Network | Required endpoints, DNS, security groups, routing and artifact access from the node | Diagnose the first failed network/source layer |
| Capacity | Available subnet addresses for any separately approved endpoint creation | Inspect IP pressure before retrying a failed create |
| Tags/metadata | Exact target tags and readable instance metadata tags | Distinguish tag mismatch from metadata access failure |

AWS documents `AmazonSSMManagedInstanceCore` and
`AmazonInspector2ManagedCisPolicy` for the instance role. Operator rights and
the node's role are different. A CIS session denial such as
`inspector2:StartCisSession` cannot be fixed merely by giving the operator
broader permissions. Check the exact managed-policy path and effective denies;
do not replace least privilege with an administrator policy.

Useful authorized reads:

```bash
aws --profile '<PROFILE>' --region '<REGION>' ssm describe-instance-information
aws --profile '<PROFILE>' --region '<REGION>' ec2 describe-instances \
  --instance-ids '<INSTANCE_ID>' \
  --query 'Reservations[].Instances[].{Id:InstanceId,Profile:IamInstanceProfile.Arn,Tags:Tags,Metadata:MetadataOptions,Subnet:SubnetId}'
aws --profile '<PROFILE>' iam list-attached-role-policies \
  --role-name '<INSTANCE_ROLE_NAME>'
aws --profile '<PROFILE>' --region '<REGION>' ec2 describe-subnets \
  --subnet-ids '<SUBNET_ID>' \
  --query 'Subnets[].{Subnet:SubnetId,Free:AvailableIpAddressCount}'
```

Keep exact results privately. A list of attached policies alone does not prove
effective permission through all IAM/SCP/boundary controls.

### Private network and metadata

The current CIS requirements identify Inspector, SSM messaging and S3 access.
The published checklist names `inspector2`, `ssm`, `ssmmessages`,
`ec2messages` and `s3`. Resolve actual Region/SSM Agent support rather than
creating this set blindly. Historical source diagnostics also checked
`inspector-scan`; it is not a universal extra CIS endpoint requirement.

Confirm private DNS and the endpoint policy, node egress and endpoint security
groups. Check the regional Inspector CIS dataset-bucket access required by
the service; an S3 endpoint alone does not prove its policy permits those
objects. Do not copy a regional bucket inventory into this guide.
`InsufficientFreeAddressesInSubnet` calls for subnet-capacity diagnosis,
not repeated endpoint creation or unapproved network expansion.

For tag-targeting failures, inspect
`MetadataOptions.HttpEndpoint`, `InstanceMetadataTags` and option state.
The source observed `Failed to get instance tags from instance metadata`
when metadata tags were disabled. If the project approves a correction,
apply it through its configuration/IaC owner and wait for state `applied`
before a diagnostic repeat. Enabling metadata tag access changes instance
behavior; this checklist is not permission to do so.

## Target precisely and preserve configuration

1. Read existing configurations; identify owner, schedule, account selection,
   benchmark level and overlapping targets.
2. Resolve tag matches to the exact intended instances before creation.
   A dedicated unique tag can prevent broad accidental scans, but adding it is
   a separate approved write. Do not rely on a shared Name/role tag alone.
3. Select the account form valid for the caller's standalone/member/delegated
   administrator role. `SELF` is documented; explicit account IDs are also
   supported. Copying a working pattern is a diagnostic clue, not proof that
   a literal account ID is invalid.
4. Confirm no active scan targets the same node; preserve any existing scan
   rather than deleting configurations to clear a conflict.
5. For an approved one-time scan, persist the request and returned configuration
   ARN. Match the resulting scan ARN, targets and scan date to this request.
   Do not accept an older scan with the same human name.

```bash
aws --profile '<PROFILE>' --region '<REGION>' \
  inspector2 list-cis-scan-configurations --output json > cis-configurations.json
```

Illustrative self-account target file and **approved scan creation only**:

```bash
jq -n --arg key '<TARGET_TAG_KEY>' --arg value '<TARGET_TAG_VALUE>' \
  '{accountIds:["SELF"],targetResourceTags:{($key):[$value]}}' > cis-targets.json
aws --profile '<PROFILE>' --region '<REGION>' \
  inspector2 create-cis-scan-configuration \
  --scan-name '<SCAN_NAME>' --security-level '<LEVEL_1_OR_LEVEL_2>' \
  --schedule '{"oneTime":{}}' --targets file://cis-targets.json \
  --output json > cis-created.json
```

An organization-owned configuration has different ownership/edit/tag rules
from a member-owned configuration. Never broaden to all accounts to avoid
an ownership/target error.

## Follow the scan, not just configuration creation

Use `list-cis-scans` with the owning account/Region and supported filters.
Preserve raw paginated results, then select the exact configuration, target and
time window. Record the scan ARN before further polling. A configuration ARN
and a scan ARN are not interchangeable.

During `IN_PROGRESS`, a zero count can be transient. Stop on a terminal
`COMPLETED`, `FAILED` or `CANCELLED` result, an explicit readiness blocker,
or the task's bounded diagnostic deadline. The source used 60–120 second polls
and observed some runs finishing in 2–5 minutes; these are dated operating
examples, not a service promise or a requirement to poll every minute.

A newly launched node may be online before all scan prerequisites settle.
The 2026 source recorded a successful retry after additional soak and suggested
15 minutes of instance age. Preserve that lesson as a readiness hypothesis,
not a mandatory sleep or proof that every early failure is harmless. Capture
state, wait for the relevant condition, reconcile the original terminal scan,
and make only a bounded authorized repeat.

## Usable result and independent promotion decision

For this runbook, usable scan evidence requires `COMPLETED` and
`totalChecks > 0`, plus retrievable check results for the intended target.
`COMPLETED` with zero checks is not security acceptance. `FAILED` or an
unavailable optional scanner does not itself prove the application/AMI failed.
Apply [TESTING's evidence-versus-promotion rules](../TESTING.md).

Report build, runtime and security states separately. A project may record
security as pending when optional evidence is invalid; that never waives a
mandatory scanner, private-network, lineage, encryption or runtime gate.
The workload chooses its compliance closure authority. No universal product
substitution or finding-count-only approval/rejection is imposed here.

Retain the complete check set before producing the actionable subset:

```bash
aws --profile '<PROFILE>' --region '<REGION>' \
  inspector2 list-cis-scan-results-aggregated-by-checks \
  --scan-arn '<SCAN_ARN>' --output json > cis-checks.json
jq '[.checkAggregations[] |
  select((.statusCounts.failed // 0) > 0) |
  {checkId,title,platform,level,statusCounts}]' cis-checks.json > cis-failed.json
```

Keep pagination enabled or deliberately collect every page. The number of
filtered records is not `totalChecks` and aggregation across targets can
change the denominator. Source observations were approximately 229 checks
for an AL2 reference, 243 for an AL2023 Level 2 run, and 289 for a hardened
clone. These are dated 2026 examples from different image/benchmark runs,
not expected constants.

## Failure map and retained lessons

| Symptom | Inspect next | Safe disposition |
| --- | --- | --- |
| Zero checks after terminal completion | Exact tags/account form, metadata tags, node role, plugin/association, dataset access, endpoint DNS | Save scan/configuration and diagnose readiness; do not infer clean compliance |
| Metadata-tag retrieval error | Metadata options and their applied state | Route an approved correction through the owner; do not repeatedly rescan unchanged state |
| `AccessDeniedException` in CIS session | Instance role's CIS policy and effective restrictions | Fix only the demonstrated permission gap under IAM authority |
| Target already belongs to another active scan / `ConflictException` | Current scan ARN, owner, schedule and terminal state | Wait/reconcile; stop duplicate schedules. Never delete all configurations as a generic recovery |
| Old `InvalidPlatform` text | Current supported OS/architecture and newest CIS plugin attempt | Prefer correlated current evidence over stale logs |
| No actionable control-plane error | Current plugin/SSM logs and target invocation | Keep source and timestamp correlation; control-plane completion can hide a node-side failure |
| Marketplace image cannot launch | Target account's product entitlement/subscription and launch permission | IAM administration is not license acceptance; use the approved current procurement path |

The source located Linux CIS diagnostics in
`/var/log/amazon/inspector/scitor.log.*`. Treat this as an installation-specific
log-location clue; confirm the current package and newest attempt. Logs may
contain private details and belong in approved evidence, not public reports.
The older statement that Marketplace terms can only be accepted in a console
is not promoted as an evergreen API limitation.

## Evidence and bounded retention

Keep scan/configuration ARN, name, benchmark, target/account/Region, scan time,
terminal status, total/failed/skipped coverage and check IDs/titles. For a
failure, add exact request/configuration, metadata options, effective-role
diagnosis, endpoint/DNS/subnet-capacity evidence and correlated node/plugin
errors. Preserve the full result and the reduced view with their relationship.

Do not terminate the validation node while a required run/evidence capture is
unfinished. For an opaque optional failure, bounded retention needs a reason,
owner and expiry; unavailability alone is not indefinite retention authority.
After required runtime evidence and the diagnostic packet are saved, follow
the project's separately authorized cleanup. See [evidence lifecycle](../KNOWLEDGE.md).

## Citations

- [Pinned source procedures and dated failure lessons](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/AWS_INSPECTOR_CIS.md)
- [AWS CIS requirements, private networking and ownership](https://docs.aws.amazon.com/inspector/latest/user/scanning-cis.html)
- [Creating a CIS configuration and SELF targeting](https://docs.aws.amazon.com/inspector/latest/user/scanning-cis-create-cis-scan-configuration.html)
- [CLI configuration request schema](https://docs.aws.amazon.com/cli/latest/reference/inspector2/create-cis-scan-configuration.html)
- [Scan status/count fields](https://docs.aws.amazon.com/cli/latest/reference/inspector2/list-cis-scans.html)
- [Paginated check aggregations](https://docs.aws.amazon.com/cli/latest/reference/inspector2/list-cis-scan-results-aggregated-by-checks.html)
- [SSM private endpoint requirements](https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-create-vpc.html)
