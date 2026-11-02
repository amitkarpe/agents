---
type: Playbook
title: Private Artifact Preflight and Recovery
status: candidate
confidence: medium
scope: Portable private package and container source procedures
review_after: 2027-01-28
tags: [artifacts, packages, registry, private, troubleshooting]
---

# Private Artifact Preflight and Recovery

An approved private source is part of the build contract. Test access from the
**actual execution host**: a developer laptop, CI runner and target instance
may have different DNS, routing, certificate trust and identity. A successful
browser login on another machine proves none of those layers.

For AWS-specific source, identity and lifecycle boundaries, use [AWS](../AWS.md).
The project owns source URLs, package versions, encryption/signing authority,
approved authentication and whether staged/offline transfer is allowed.

## Diagnose the failing layer

| Layer | Read-only evidence | What it does not prove |
| --- | --- | --- |
| DNS | Approved hostname resolves on execution host | TLS or application reachability |
| Transport/TLS | Expected service and certificate verified | Authentication or repository permission |
| Authentication | Intended identity accepted by service | Access to this object/version |
| Metadata | Exact repository/package/tag metadata visible | Artifact bytes downloadable or usable |
| Artifact | Exact bytes/digest/signature obtained | Target installation, boot or runtime consumption |
| Consumption | Approved target uses exact artifact successfully | Other targets or future versions |

Use bounded probes against an owner-provided hostname and URL:

```bash
getent hosts "$approved_host"
curl --connect-timeout 5 --max-time 10 --silent --show-error \
  --output /dev/null --write-out '%{http_code}\n' "$approved_metadata_url"
```

These timeouts are example bounds for a small probe, not universal workload
limits. Confirm the response is from the intended service: a proxy can return
its own error page. A 401/403 from that service establishes some connectivity
but is **not** successful authentication or artifact access. Inspect TLS errors
as trust/hostname/chain problems; do not bypass verification with `-k`.

Keep verbose network output, repository URLs containing credentials and full
error bodies in approved private evidence. Share a sanitized failing layer,
status, exact nonsecret version and next action.

## RPM/DNF source procedure

1. Inspect the approved repository configuration and enabled repository IDs.
   `dnf repolist --verbose` can expose authenticated URLs; inspect privately.
2. Query the exact package: `dnf list --showduplicates "$package"`. Confirm
   version, release, architecture and dependency sources match the project.
3. Resolve the proposed transaction with `dnf install --assumeno "$package_spec"`.
   This is a dependency/transaction preview, not installation success.
4. Check the project's package signature, trusted signing key and repository
   metadata signature requirements. `gpgcheck` and `repo_gpgcheck` protect
   different things; do not disable either to make a transaction succeed.
5. Only under install authority, perform the approved transaction. Read back
   installed version/architecture, for example `rpm -q "$package"`, and run the
   existing target acceptance check.

A metadata listing may work while a package download, dependency or signature
fails. Diagnose that exact step. Do not switch silently to a public repository,
relax TLS/GPG/SELinux/network restrictions or install a nearby version.

## Container source procedure

Use a fully qualified approved registry/repository and the project-selected
tag or digest. Resolve mutable tags before freezing provenance when the
contract requires immutable bytes.

```bash
docker image inspect "$approved_image" \
  --format '{{json .RepoDigests}}'
docker image inspect "$approved_image" \
  --format '{{.Os}}/{{.Architecture}}'
```

An existing local image may be stale; distinguish local inspection, registry
metadata, authorized pull and actual target execution. Match platform,
manifest/digest and required signing/attestation policy. A listing or dry run
is not target consumption. Do not use a public lookalike image as fallback.

Authentication belongs to the approved secret mechanism; never put a password
or token in a command argument or publish registry auth configuration. A missing
login does not authorize reading someone else's credentials.

## Recovery and durable correction

Record the exact failing host/layer/object and preserve the original error
privately. If the approved private service is unavailable, stop or use an
explicitly approved staged-artifact path with provenance, digest, signatures
and dependency completeness. Offline acceptance still belongs to the target.

After proving a fix, update the owning durable repository/configuration under
its approval. A manual host edit is diagnostic evidence, not a new baseline.
Do not turn a successful temporary workaround into undocumented permanent
source drift.

## Citations

- [Pinned source procedure and provenance](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/nexus.md)
- [DNF command reference](https://dnf.readthedocs.io/en/latest/command_ref.html)
- [Docker image inspect](https://docs.docker.com/reference/cli/docker/image/inspect/)
- [curl manual](https://curl.se/docs/manpage.html)
