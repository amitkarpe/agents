---
type: Playbook
title: AMI Lineage, Sharing and Target Consumption
description: Verify image provenance, snapshot/key branches and actual target use before promoting an AMI pointer.
status: candidate
confidence: high
scope: Authorized EC2 image build/share/copy/consumption workflows; encryption and promotion policy remain project-owned
last_verified: 2026-10-28
review_after: 2027-01-28
tags: [aws, ami, ebs, kms, images, lineage, promotion]
---

# AMI Lineage, Sharing and Target Consumption

Use [AWS](../AWS.md), the project's IaC/image pipeline and its approved
encryption/lineage policy. There is no canonical unencrypted-first,
copy-first or shared-source-first preference. The source notes contained
conflicting local preferences; neither becomes global policy.

## Build and provenance contract

Before a Packer/Image Builder request, identify source image/owner/Region,
approved base lineage, intended network, versioned build inputs, expected
image/snapshot outputs and temporary-resource retention. Use
[AWS-owned execution](OIDC.md#image-build-requests), not process exit alone.
Disposable proof resources do not authorize changing shared networking,
IAM, endpoints or security groups outside their IaC owner.

Keep the source AMI ID and name, immutable recipe/component or Packer revision,
build method/lane, timestamps, output image and all backing snapshots,
encryption/key identity, validations and approval reference.
An image tag asserting a baseline is not independent provenance.
Inspect and sanitize the captured image for secrets/data under the project.

Human metadata should identify workload, environment, purpose, revision,
source/base, build method, owner and creation/retention state. Do not encode
assistant names as approval authority. Source tag names, timestamp formats
and approval values remain project-specific.

## Resource metadata, current pointer and history are different

| Surface | Responsibility |
| --- | --- |
| AMI name/description/tags | Discoverable resource-local identity and source context |
| Current parameter/launch-template pointer | The selected current image/version for a lane |
| Versioned registry/history | Build, copy/share, validation and promotion sequence with evidence |
| Artifact/evidence store | Build output, manifests, logs and readbacks; not by itself promotion history |

A useful registry entry includes image ID/name/description summary,
source image/owner/name/parameter, workload/project, build method/lane/revision,
environment, creation time, retention, approved/pending disposition and
evidence reference. Record a copy as a new image with a parent relationship;
do not overwrite the parent's history.

Report human identity and provenance alongside an image ID. Public results
use aliases; actual account IDs, key ARNs and deployment inventory stay in
the project's protected records. An expired source table is not cleanup
authority.

## Inspect actual snapshots and keys first

For an authorized source-account read:

```bash
aws --profile '<SOURCE_PROFILE>' --region '<REGION>' ec2 describe-images \
  --image-ids '<AMI_ID>' \
  --query 'Images[].{Id:ImageId,Name:Name,Owner:OwnerId,State:State,Created:CreationDate,Devices:BlockDeviceMappings}'
aws --profile '<SOURCE_PROFILE>' --region '<REGION>' ec2 describe-snapshots \
  --snapshot-ids '<SNAPSHOT_ID>' \
  --query 'Snapshots[].{Id:SnapshotId,Owner:OwnerId,Encrypted:Encrypted,KmsKeyId:KmsKeyId,State:State}'
aws --profile '<SOURCE_PROFILE>' --region '<REGION>' kms describe-key \
  --key-id '<KEY_ID_OR_ARN>' \
  --query 'KeyMetadata.{Arn:Arn,Manager:KeyManager,State:KeyState}'
```

Enumerate every EBS-backed device rather than only the root snapshot. A key
alias, naming convention or remembered default does not prove key ownership
or manager type. Metadata reads and key-policy/grant reads have their own
permissions; inability to inspect them is an evidence gap, not permission
to change encryption.

## Branch by actual encryption and intended operation

| Observed backing storage | Cross-account decision |
| --- | --- |
| Unencrypted EBS snapshots | AMI sharing can be possible; target encryption policy may still require encrypted launch volumes or an approved encrypted copy |
| Customer-managed KMS key | Verify target use of the key and caller/service-role permissions as well as AMI launch permission |
| Default AWS-managed EBS key | AMIs backed by those encrypted snapshots cannot be shared directly across accounts; propose an authorized customer-managed-key copy/rebuild path |
| Mixed/missing/inaccessible evidence | Resolve every device/key branch before declaring target readiness |

Do not remove encryption to fit a convenient sharing path. Rebuild/copy,
new keys, grants, policy changes and target-owned images are separate
mutations within the project's approval envelope. Copy/re-encryption can
incur full-snapshot storage/transfer costs and creates new lineage.

### AMI launch permission is not direct snapshot-copy permission

AWS documents that sharing an AMI provides access to its referenced EBS
snapshots **for that AMI launch**; separate snapshot sharing is not required
solely for this path. Encrypted backing snapshots still require authorized
KMS-key use. This corrects the source's blanket rule to explicitly share
every snapshot before any shared-AMI launch.

Direct snapshot consumption or copying a shared AMI is a different path:
verify the required backing-storage read/create-volume permissions and key
access for the actual operation. Preserve source snapshot permissions and
target readbacks where that path needs them; do not grant them automatically
to solve an unrelated launch problem.

Authorized permission inspection, from the appropriate owner:

```bash
aws --profile '<SOURCE_PROFILE>' --region '<REGION>' ec2 describe-image-attribute \
  --image-id '<AMI_ID>' --attribute launchPermission
aws --profile '<SOURCE_PROFILE>' --region '<REGION>' ec2 describe-snapshot-attribute \
  --snapshot-id '<SNAPSHOT_ID>' --attribute createVolumePermission
```

No blanket `all` permission, KMS wildcard grant or mutation command is
prescribed. The owner reviews exact grantees and records before/after
permissions. Customer-managed key sharing involves both source key policy
and target IAM; EC2/Auto Scaling service roles and grants must be appropriate
for the real launch path. A human operator's successful read is not proof
that a workload service role can launch.

## Prove target consumption before promotion

1. In the target account/Region, confirm the exact shared/copied image is
   visible and its source/owner match the candidate. Do not silently select
   a newer image by name.
2. Resolve block-device encryption defaults/overrides and all required key
   permissions for the target caller and actual launch service.
3. Use the approved target launch template/request for an authorization dry
   run where useful. A `DryRunOperation` response is an expected permission
   signal, not a boot, KMS-grant, storage or application validation.
4. If the acceptance requires real launch, run only the authorized bounded
   target consumption, preserve image/instance/volume/key evidence, and
   validate network, SSM and workload behavior. Reconcile delayed launch or
   key failures instead of assuming the initial request proved success.
5. Record whether consumption is shared-source or target-owned-copy, the
   target evidence and independent runtime/security state. Update the current
   pointer only through the project's promotion gate.
6. Save rollback's previous pointer/template version and retained dependencies.
   Cleanup follows explicit ownership/retention authority, not a passing scan
   or an old TTL instruction.

Read-only target visibility example:

```bash
aws --profile '<TARGET_PROFILE>' --region '<REGION>' ec2 describe-images \
  --image-ids '<CANDIDATE_AMI_ID>' --output json
```

Do not substitute source-account visibility for target-account proof.
Image-local tags/descriptions may not be reproduced as target metadata;
carry required lineage in the owned registry/launch workflow.

## Governance: detective checks and preventive limits

AWS Config approved-image rules evaluate configuration; they are not the
same as a preventive launch deny. Allowed AMIs criteria can restrict public/
shared-image discovery/use when enabled; audit mode previews rather than
blocks, and account-owned images are outside that restriction.
Do not claim this feature alone enforces the project's complete lineage
policy. Use the approved image pipeline, launch/IAM/organization controls and
actual readbacks. Do not invent an SCP or claim tag assertions prove ancestry.

If promotion fails, classify the failed layer: approved source/lineage,
AMI visibility/permission, snapshot-copy access, encryption/key manager,
caller versus service-role KMS use, Region/network, runtime or security
acceptance. Keep scanner failure and image launch failure distinct; see
[Inspector](INSPECTOR_CIS.md) and [Testing](../TESTING.md).

## Citations

- [Pinned image/lineage/sharing source sections](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/AWS.md#ami-lineage-registry-rule-hard)
- [Pinned sanitized DEV template](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/dev_env.template.md)
- [Pinned sanitized production template](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/prod_env.template.md)
- [AWS AMI sharing: launch permission, snapshots and keys](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/sharingamis-explicit.html)
- [AMI copy and backing-storage permissions](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/how-ami-copy-works.html)
- [Encryption at image launch/copy](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIEncryption.html)
- [Cross-account snapshot key permissions](https://docs.aws.amazon.com/ebs/latest/userguide/share-kms-key.html)
- [RunInstances dry-run semantics](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_RunInstances.html)
- [Allowed AMIs scope and audit mode](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-allowed-amis.html)
- [AWS Config approved AMI evaluation](https://docs.aws.amazon.com/config/latest/developerguide/approved-amis-by-id.html)
