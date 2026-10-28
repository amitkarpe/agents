---
type: Playbook
title: GitLab Runner Connected Preparation
description: Use GitLab as an internal execution plane for connected preparation while keeping source authority, runner health, short-lived identity, and offline runtime boundaries explicit.
status: reviewed
scope: GitHub-primary repositories mirrored to GitLab for CI/CD and connected preparation
confidence: high
timestamp: 2026-09-18T13:52:00+08:00
last_verified: 2026-09-18
review_after: 2027-03-18
tags: [gitlab, github, runner, mirror, oidc, ci, preparation, security, offline]
---

# GitLab Runner Connected Preparation
> **Ownership:** This specialist guide documents one bounded topic. The
> canonical [Core](CORE.md), [Goals](GOALS.md),
> [Context](CONTEXT.md) and [Safety](SAFETY.md)
> rules govern reusable authority and evidence. Project rules and local
> provider/host configuration still take precedence. A documented command or
> reference is not proof of current runtime support.


Use GitLab Runner as a replaceable connected execution host, not as the source of application truth.

One supported pattern (only when selected by the owning project):

    canonical source repository
      -> internal GitLab pull mirror
      -> current GitLab Runner
      -> connected preparation
      -> short-lived cloud identity when required
      -> bounded internal artifact publication
      -> offline/private runtime

## 1. Keep one source authority

When the project selects a GitHub-primary pull mirror, use GitHub -> GitLab
Pull mirror -> GitLab CI/Runner. Other projects may explicitly select controlled
main-only publication and forbid native repository mirroring. Verify that
actual model; this guide does not normalize one into the other or authorize
changing settings. GitLab-primary repositories are separately governed.

Do not configure push or bidirectional mirroring unless the project explicitly requires a different authority model.

Mirror acceptance must be based on real refs and SHA equality, not a UI status alone:

    MIRROR_DIRECTION=Pull
    SOURCE_MAIN_SHA=<sha>
    TARGET_MAIN_SHA=<same sha>
    TARGET_MAIN_EXISTS=true
    RESULT=PASS

## 2. Prove a current Runner first

Historical Runner success is architectural evidence, not current capacity. Before CI work record Runner availability, status, executor, architecture, and tags.

Runner discovery itself is a safety gate:

1. paginate every project/group Runner listing available to the caller;
2. read candidate Runner details rather than trusting only the list row;
3. treat an admin-only global Runner API returning 403 as a visibility limitation, not proof that no project-visible Runner can execute;
4. require one actually scheduled job before declaring a Runner tag usable.

A first API page can contain only stale historical entries while later pages contain current pools. Do not make an availability decision from page 1 alone.

A stale, paused, offline Runner, or one backed by deleted compute, is a platform-availability problem. If repository automation has no runner-administration authority, classify it as:

    RESULT=BLOCKED
    BLOCKER=RUNNER_ADMIN_ACTION_REQUIRED

Stop before application preparation.

## 3. Use the cheapest preflight first

Advance in this order:

1. current Runner;
2. architecture and executor;
3. outbound Internet to one approved public endpoint;
4. required local tools;
5. short-lived identity if cloud access is needed;
6. bounded storage/registry access;
7. application-specific preparation.

A generic health result is:

    RUNNER_AVAILABLE=PASS
    RUNNER_INTERNET=PASS
    REQUIRED_TOOLS=PASS
    RESULT=PASS

Stop at the first meaningful blocker.

### Evidence-based sizing

Choose Runner size from measured workload behavior rather than names alone.

A useful default progression is:

    small -> intake, lint, short discovery
    medium -> normal connected preparation
    large -> image-heavy or artifact-heavy preparation
    xlarge -> only after a measured capacity failure justifies it

Record CPU, memory, scratch disk, queue/start delay, run time, and representative image/artifact behavior before standardizing a size.

Prefer the architecture required by the target workload. For x86_64 container and workflow targets, validate amd64 first; use Arm only when specifically required or beneficial.

## 4. Keep CI orchestration thin

CI configuration should call repository-owned scripts. Do not duplicate discovery, build, migration, validation, or release logic inside a large .gitlab-ci.yml.

Prefer: GitLab CI -> generic runner-health script -> project-owned preparation command -> compact evidence artifact.

## 5. Use a dedicated preparation image when needed

Hosted or autoscaled runners often begin with a minimal job image. If tools are missing, use a dedicated preparation image and record its immutable image digest plus tool versions.

Do not assume Docker-in-Docker is available. Unprivileged runners may reject privileged Docker builders. Use an approved rootless/unprivileged builder or a prebuilt preparation image.

Keep the preparation image separate from application/runtime images.

Treat preparation identity as a compact immutable set:

    source revision
    preparation image digest
    exact required tool versions
    compact result/evidence

For bootstrap installers that read environment variables, ensure the variable reaches the shell that performs installation and assert the resulting version. A successful download of an unpinned latest version is not an equivalent proof.

For Python CLIs on externally-managed system Python installations, prefer an isolated virtual environment over modifying the system interpreter.

## 6. Prefer short-lived workload identity

When a Runner must access a cloud account, prefer CI-native OIDC/workload identity over static keys.

Use identity-first sequencing: Runner -> CI ID token -> cloud STS/workload identity -> temporary credentials -> identity readback only.

First prove:

    OIDC_TRUST=PASS
    CLOUD_IDENTITY=PASS
    RAW_TOKEN_RECORDED=NO
    TEMPORARY_CREDENTIALS_RECORDED=NO

Do not grant storage, registry, deployment, or administration rights as part of the identity proof.

Run identity-only proof from an already trusted project/ref. Do not widen workload-identity trust merely to make a temporary test branch succeed.

## 7. Add data-plane access incrementally

After identity succeeds, add only the smallest required scope: one storage prefix, one registry namespace, read-only metadata, or one disposable smoke object/image.

Keep evidence truthful. If an out-of-scope deny test was not run, record NOT_RUN rather than inventing PASS.

## 8. Separate connected preparation from offline runtime

Connected preparation may fetch source, inspect dependencies, resolve plugins/images, and stage approved assets. Offline/private runtime must consume only staged internal artifacts.

Do not infer offline-runtime proof merely because connected preparation succeeded.

When AWS-local validation or promotion belongs inside the cloud trust boundary, use a clean handoff:

    GitLab Runner -> immutable prepared handoff / control call -> CodeBuild -> private AWS path

Do not try to run a GitLab Runner inside CodeBuild. Treat the two execution planes as complementary: Runner for connected preparation/control, CodeBuild for AWS-account-local validation or promotion.

## 9. Mirror-compatible repository policy

Externally authored history may conflict with project push rules that assume every commit was authored, signed, or mapped to a local GitLab user.

For a pull-mirror repository, evaluate verified-user-only authorship, mandatory local-user mapping, and mandatory commit-signing rules for technical compatibility. Do not weaken group or instance policy globally. Apply only the smallest approved repository-level exception.

Keep secret-detection controls enabled unless an owning security policy says otherwise.

## 10. Common failure modes

- Wrong mirror direction: verify Pull for source -> GitLab use cases.
- Green mirror status but no refs: inspect branches/commits and compare SHAs.
- Runner stale/offline: paginate first, inspect candidate detail, then classify as external platform/admin recovery only after scheduling cannot find a usable pool.
- Global Runner API returns 403: treat it as an authorization/visibility limit, not a Runner-availability result.
- Tools absent: use a preparation image; keep CI YAML thin.
- Privileged Docker unavailable: use approved unprivileged/rootless build.
- OIDC failure: verify issuer, audience, subject/project/ref constraints, and trust before changing permissions.
- Architecture mismatch: record Runner architecture before selecting images or native binaries.

## 11. Minimal evidence packet

    SOURCE_AUTHORITY=
    MIRROR_DIRECTION=
    SOURCE_MAIN_SHA=
    TARGET_MAIN_SHA=
    MIRROR_RESULT=
    RUNNER_AVAILABLE=
    RUNNER_STATUS=
    RUNNER_DISCOVERY_PAGINATED=PASS|BLOCKED
    RUNNER_SCHEDULE_PROOF=PASS|BLOCKED|NOT_RUN
    RUNNER_EXECUTOR=
    RUNNER_ARCHITECTURE=
    RUNNER_TAGS=
    RUNNER_INTERNET=
    REQUIRED_TOOLS=
    WORKLOAD_IDENTITY=PASS|NOT_REQUIRED|BLOCKED
    DATA_PLANE_ACCESS=PASS|NOT_REQUIRED|NOT_RUN
    APPLICATION_PREPARATION=PASS|BLOCKED|NOT_RUN
    RESULT=PASS|BLOCKED|FAIL
    NEXT=<one action>

Keep evidence compact and non-secret.

## 12. Promotion boundary

Project repositories own scripts, CI files, permissions, runner tags, and runtime evidence. Agent OS owns reusable policy and sequence guidance. Local host/tool defaults belong in local/dotfiles guidance.

Do not turn Agent OS into a copy of one project implementation.

## 13. Host, MR and push-rule diagnostics

This guide is knowledge, not permission to authenticate, publish or change
GitLab settings. First bind the intended host/project, remote, current identity,
approved source model and exact branch SHA. A local SSH account key does not
provision GitLab's server-side mirror credential.

For an authorized diagnostic read, with host/project chosen by the owner:

```bash
git remote -v
glab config get host
glab auth status --hostname "$approved_gitlab_host"
glab api --hostname "$approved_gitlab_host" "projects/$approved_project_id/push_rule"
```

Inspect authentication output privately; do not print tokens/configuration.
Wrong host, wrong remote protocol, wrong identity, missing project permission
and inherited push rules are different failures. A 403 may be a visibility
limitation; it is not proof that a project/runner does not exist.

Normal issue/MR command shapes include `glab issue view <id>`,
`glab mr create --draft`, `glab mr view <id>` and `glab mr update <id>`.
Use the owning project's readiness, body and merge rules; “draft early” is a
workflow option, not authority to create duplicate MRs or merge them. Keep the
problem/result, validation and material risk concise; link the owning issue
using that project's resolver convention.

### Inspect fields before proposing a change

| Concern | Project push-rule field |
| --- | --- |
| Committer email belongs to the pusher's verified emails | `commit_committer_check` |
| Commit author name consistent with GitLab account name | `commit_committer_name_check` |
| Signed commits | `reject_unsigned_commits` |
| DCO requirement | `reject_non_dco_commits` |
| Tag deletion | `deny_delete_tag` |
| Author membership | `member_check` |
| Secret-file prevention | `prevent_secrets` |

Inspect current API/version semantics and inherited policy before interpreting
these fields. Keep secret prevention enabled unless a separately reviewed
exception explicitly covers it. Never translate this table into a blanket
“set everything false” migration profile.

Some API fields return null when disabled; an unconfigured project can return
a different null-shaped response. Do not coerce every missing/null value into
an asserted false setting or assume a project response exhausts inherited policy.

For example, **only if the exact project/field/value exception has been
approved**, the API shape for changing one field and reading it back is:

```bash
glab api --hostname "$approved_gitlab_host" --method PUT \
  "projects/$approved_project_id/push_rule" \
  --field commit_committer_check=false
glab api --hostname "$approved_gitlab_host" \
  "projects/$approved_project_id/push_rule"
```

Preserve the private preimage, compare every relevant field after the update,
and verify the selected exception actually took effect. Do not expand the
exception if a group/instance policy still blocks publication. Report that
authority boundary. This changes neither branch protection, authentication,
CI controls nor authorization to publish. Preserve canonical history rather
than rewriting/re-signing it merely to satisfy a secondary's inherited rules.

A claimed publication needs accepted target ref/SHA and side-effect evidence,
not only API success or an MR/mirror UI label. Respect the selected main-only
scope, pending writers, ancestry/no-force checks and existing CI triggers.

## Citations

- https://github.com/amitkarpe/nextflow-offline/issues/22
- https://github.com/amitkarpe/nextflow-offline/pull/23
- https://github.com/amitkarpe/nextflow-offline/pull/25
- https://github.com/amitkarpe/nextflow-offline/issues/26
- https://github.com/amitkarpe/nextflow-offline/pull/27
- https://github.com/amitkarpe/nextflow-offline/issues/28
- https://github.com/amitkarpe/nextflow-offline/pull/29
- https://github.com/amitkarpe/nextflow-offline/pull/39
- https://github.com/amitkarpe/cloudos-offline/pull/6
- [Pinned GitLab diagnostics and project-authority distinction](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/GITLAB.md)
- [GitLab project push rules API](https://docs.gitlab.com/api/project_push_rules/)
- [GitLab CLI reference](https://docs.gitlab.com/cli/)
