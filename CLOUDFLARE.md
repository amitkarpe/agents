---
type: Practice
title: Cloudflare Worker Demo Deployment
description: Reusable Cloudflare Workers demo publication, custom domains, public access, email allowlists, and GitHub configuration.
status: reviewed
scope: synthetic Cloudflare Workers demos
confidence: high
timestamp: 2026-10-19T00:00:00+08:00
review_after: 2027-04-19
tags: [cloudflare, workers, access, github-actions, dns, deployment]
---

# Cloudflare Worker Demo Deployment
> **Ownership:** This specialist guide documents one bounded topic. The
> canonical [Core](AGENTS.md), [Goals](GOALS.md),
> [Context](CONTEXT.md) and [Safety](SAFETY.md)
> rules govern reusable authority and evidence. Project rules and local
> provider/host configuration still take precedence. A documented command or
> reference is not proof of current runtime support.


**Purpose:** publish reviewed, synthetic-only demos using a dedicated Cloudflare Worker and branded custom domain. This is reusable guidance, not account authorization. The owning repository Issue/SPEC and live provider evidence decide what is permitted.

## Access options

| Mode | Visitor experience | Setup | Consideration |
|---|---|---|---|
| PUBLIC | Open URL, no login | Dedicated Worker and custom domain, no Access challenge | Suitable for strictly synthetic demos; content can be copied by anyone |
| EMAIL_ALLOWLIST | Allowed email receives one-time PIN | Cloudflare Access self-hosted app, explicit Allow emails and OTP method | Individual identity control; 5–10 reviewers is practical |
| SHARED_SECRET_GATE | Shared long passphrase | Custom server-side Worker secret plus validated session, expiration and rate limiting | Shareable credential, no individual audit; NOT Cloudflare Access OTP |

**Do not put passwords in HTML, browser JS, URLs, Git history, GitHub Variables, or screenshots.** For a public synthetic showcase, prefer PUBLIC rather than inventing a new password gate.

## PUBLIC Worker runbook

1. Reconcile current repository Issue, exact approved Git commit, static asset allowlist and package hash. Review for secrets, real account IDs, customer information, private incident data, outbound network calls and third-party scripts.
2. Read current Cloudflare account, Workers, existing domains, DNS, Access applications and routes before touching anything. Select a **distinct** Worker and unused hostname.
3. Deploy only the reviewed source package. Capture Worker name, provider version/deployment identity, Git SHA, package hash and rollback identity. Repository merge alone is not deployment.
4. Bind the approved subdomain via **Worker custom domain** in the correct zone. Avoid overlapping an existing Worker, DNS record or route. Keep preview endpoints disabled unless requested.
5. PUBLIC means no login challenge at **all reachable hostnames**, including an active workers.dev URL. Do not alter unrelated Access applications or broad Zero Trust settings.
6. Test from an unauthenticated browser session: correct HTTPS URL, no email OTP, correct version, working MOCK journey and exported evidence with REAL_WRITES=0.
7. Retain a short sanitized release receipt. A successful domain API response does not by itself prove TLS, DNS propagation or anonymous-browser acceptance.

## Deployment lessons checked across five repositories

The following source contracts and retained public evidence were reviewed on
2026-10-19. The pinned sources and existing run/acceptance records are listed in
Citations. This review did not rerun deployments, browser journeys or cloud tests;
the five repositories do not all claim the same level of live deployment proof.

| Repository | Checked evidence | Reusable lesson |
| --- | --- | --- |
| `kcloud1/cloud-app-factory` | A successful manual Actions run completed only its `plan` job. The no-write release contract explicitly reports `APPROVAL_REQUIRED` / `PLAN_ONLY`. | A green plan or gate report is not a deployment. Bind reusable workflow identity to a reviewed full commit; credentials in the factory repository do not automatically become caller credentials. |
| `kcloud1/factory-pilot` | Its protected-main push run completed `check`, `publish / build` and `publish / deploy` successfully at the same source SHA; the caller pins the factory publisher by full SHA. | Use one deployment writer. Build without provider credentials, pass only that run's immutable artifact to the deployment job, and retain source/release metadata for independent parity checks. |
| `kcloud1/cloud-ops-demo` | The accepted Level 4 receipt supersedes earlier direct-upload history: native `push_event`, exact merged SHA, provider build/deployment/version, traffic and two live UI checks are correlated. | Distinguish manual snapshots from automatic Git releases. A provider label of `wrangler` alone does not identify the trigger, and a successful deployment does not establish the credential's full scope. |
| `kcloud1/codex-cloud-hello-site` | The source separates static Pages behavior from the Worker's `/api/hello` route and explicitly leaves new live API behavior unverified. Its asset allowlist contains only the three frontend files. | A working static page is not backend proof. Check the API route separately; confirm the entry point, asset root and route ordering, and exclude repository/configuration files from hosted assets. |
| `kcloud1/aws-factory-pilot` | Its Cloudflare onboarding guide and optional starter are opt-in preparation, not this repository's deployment receipt. The guide distinguishes repository access, provider GitHub App grants and native Builds configuration. | Confirm the exact repository grant, existing Worker, production branch, root and deploy command. Decide native Builds versus Actions once; do not add a competing pipeline to bypass missing access or setup. |

For Git-triggered acceptance, correlate the full **merged** commit, actual event,
terminal build/run, deployed version and traffic. A manual retry or deploy hook is
different evidence. A custom hostname needs its own HTTPS/content observation;
workers.dev success or a domain binding alone does not establish that result.
Reuse existing accepted proof and perform only the app-relevant checks needed by
the owning release; do not rerun a reference project to validate this playbook.

Choose production `workers_dev` and `preview_urls` independently: turning off
preview URLs does not disable the production workers.dev hostname. For a
custom-domain-only release, verify both are off; for an approved public alias,
verify that alias separately. Neither choice grants new audience authority.

## Restrict access later: 5–10 reviewer emails

In Cloudflare Zero Trust → Access → Applications, configure a self-hosted application for the exact hostname (and alternative Worker URLs where necessary). Configure One-time PIN or another approved identity provider. Add a policy with **explicit email addresses**. Do NOT create an Allow rule for Everyone or all OTP users. Test an allowed and a disallowed identity; verify there is no workers.dev bypass. Keep private reviewer email lists outside the public KB.

## Optional shared passphrase

A shared password requires a custom **server-side** gate with a Worker secret, constant-time verification, rate limiting, HTTPS-only HttpOnly session cookie, expiration and revocation. A shared string is easier to redistribute than an identity-based credential; avoid this implementation for ordinary public synthetic demos.

## GitHub Actions configuration

| Optional key | Store in | Meaning |
|---|---|---|
| CLOUDFLARE_ACCOUNT_ID | GitHub Actions Variable | Non-secret, intended account reference |
| CLOUDFLARE_ZONE_ID | GitHub Actions Variable | Target DNS zone when a custom hostname is used |
| CLOUDFLARE_WORKER_NAME | GitHub Actions Variable | Distinct per-project Worker name |
| CLOUDFLARE_CUSTOM_DOMAIN | GitHub Actions Variable | Explicit approved hostname |
| CLOUDFLARE_API_TOKEN | GitHub Actions encrypted Secret, only if genuinely needed | Least-privilege credential for target Worker deployment |

**Only placeholders/key names belong in Agent OS.** Exact approved account/zone/Worker/hostname configuration belongs in the application repository. Reconcile that repository's current workflows and settings metadata first. If no deployment workflow consumes a token, leave it absent; an interactive connected OAuth release does not require copying its credential into CI.

### Set approved non-sensitive variables

Replace every placeholder with independently verified project facts. A domain variable does not create a domain binding or authorize DNS, Access or unrelated Worker changes. Preserve unrelated repository settings.

```bash
set +x
cf_repo=OWNER/REPOSITORY
cf_account_id=APPROVED_ACCOUNT_ID
cf_zone_id=APPROVED_ZONE_ID
cf_worker_name=APPROVED_WORKER_NAME
cf_custom_domain=APPROVED_HOSTNAME
gh variable list --repo "$cf_repo" --json name,updatedAt
gh secret list --repo "$cf_repo" --json name,updatedAt
gh variable set CLOUDFLARE_ACCOUNT_ID --repo "$cf_repo" --body "$cf_account_id"
gh variable set CLOUDFLARE_ZONE_ID --repo "$cf_repo" --body "$cf_zone_id"
gh variable set CLOUDFLARE_WORKER_NAME --repo "$cf_repo" --body "$cf_worker_name"
gh variable set CLOUDFLARE_CUSTOM_DOMAIN --repo "$cf_repo" --body "$cf_custom_domain"
gh variable list --repo "$cf_repo" --json name,updatedAt
gh secret list --repo "$cf_repo" --json name,updatedAt
```

Report requested keys as `SET`, `ALREADY_SET` or `BLOCKED`, and an optional unused token as `NOT_REQUIRED`. Metadata proves names/timestamps, not stored values or a working deployment. Retain the approved non-sensitive write payload; do not infer correct values from a name alone or retrieve values just to produce a readback report.

### Add a credential only for a real deployment workflow

- Verify provenance, account, expiry and effective scope without exposing the credential. A successful account read does not prove write permission. Prefer a supported connected identity or managed credential; never export connector/Codex OAuth storage into GitHub or reuse a credential known to have been disclosed.
- Limit authority to the supported target Worker resource/role. Changing Routes or Custom Domains also needs permission on the affected zone; deploying content to an already-bound Worker need not change either. Do not grant unrelated DNS, Access or account administration.
- Prefer an approved protected deployment environment. Repository secrets have no per-workflow ACL; an environment also permits another authorized workflow to name it. Audit who can edit workflows/environment controls and restrict secret references to the intended deployment job. Stop if the required isolation cannot be enforced. Keep credentials out of pull-request checks and other untrusted code paths.
- Never put a token in Variables, `--body`, an inline environment assignment, logs, screenshots or Git. Never bulk-import an environment file or print it through a redaction filter: comments and unrelated keys may contain secrets. If a local source is necessary, use an allowlisted trusted parser with no value output and an in-memory stdin transfer; do not source arbitrary file content.

For an already-approved environment, the CLI can prompt for the secret without placing its value in shell history, then list metadata only:

```bash
set +x
cf_environment=APPROVED_DEPLOYMENT_ENVIRONMENT
gh secret set CLOUDFLARE_API_TOKEN --repo "$cf_repo" --env "$cf_environment"
gh secret list --repo "$cf_repo" --env "$cf_environment" --json name,updatedAt
```

Only the reviewed deployment job should reference `secrets.CLOUDFLARE_API_TOKEN`. Non-sensitive configuration uses `vars.CLOUDFLARE_ACCOUNT_ID`, `vars.CLOUDFLARE_ZONE_ID`, `vars.CLOUDFLARE_WORKER_NAME` and `vars.CLOUDFLARE_CUSTOM_DOMAIN`. GitHub's secret metadata API does not return stored secret values. Do not create a token, workflow or deployment merely to make the settings checklist look complete.

## Acceptance

- [ ] Exact account, Worker and hostname approved; no existing Worker overwritten
- [ ] Assets reviewed as public-safe and synthetic-only
- [ ] Git source SHA, package checksum, deployment/version receipt and rollback recorded
- [ ] Worker domain resolves to the intended service
- [ ] All endpoints honor the selected access mode
- [ ] PUBLIC: truly anonymous browser works without an OTP
- [ ] EMAIL_ALLOWLIST: approved email succeeds and disallowed email is blocked
- [ ] Visible MOCK/SYNTHETIC label and no claims of real provider writes
- [ ] No secrets copied to GitHub or logs; cost assumptions are labeled accurately

## Reuse

This Markdown is the canonical general reference. Link it from project-specific Issues and AGENTS files instead of copying it. Consider a small Skill only when multiple agents need repeatable readback/deploy/rollback tool orchestration; any Skill should reference this playbook, not duplicate it.

## Citations

- [Workers custom domains](https://developers.cloudflare.com/workers/configuration/routing/custom-domains/)
- [Workers Cloudflare Access](https://developers.cloudflare.com/workers/configuration/cloudflare-access/)
- [Cloudflare Access policies](https://developers.cloudflare.com/cloudflare-one/access-controls/policies/)
- [GitHub Actions secrets and variables](https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions)
- https://cli.github.com/manual/gh_variable_set
- https://cli.github.com/manual/gh_variable_list
- https://cli.github.com/manual/gh_secret_set
- https://cli.github.com/manual/gh_secret_list
- https://developers.cloudflare.com/workers/authorization/workers/

### Pinned repository contracts and existing deployment evidence

- https://github.com/kcloud1/cloud-app-factory/blob/fbbea5e289e552d357143ee27d2bbe00d76cedc1/docs/RELEASE_GATE.md
- https://github.com/kcloud1/cloud-app-factory/actions/runs/38068725435
- https://github.com/kcloud1/factory-pilot/blob/3eabe4d0e1eccdc88f57ca34d4204c309124bb11/.github/workflows/pilot.yml
- https://github.com/kcloud1/factory-pilot/actions/runs/38093719264
- https://github.com/kcloud1/cloud-ops-demo/issues/5#issuecomment-6094650672
- https://github.com/kcloud1/cloud-ops-demo/blob/d0e61e0037b7841cb27a40758c0bd3f93c2e9095/wrangler.jsonc
- https://github.com/kcloud1/codex-cloud-hello-site/blob/9b637d9a456db297b0a2f3767a3746146bc5d50e/README.md
- https://github.com/kcloud1/codex-cloud-hello-site/blob/9b637d9a456db297b0a2f3767a3746146bc5d50e/.assetsignore
- https://github.com/kcloud1/aws-factory-pilot/blob/bf203e70474f39056b9cb1ff5755288af35ed39c/docs/CLOUDFLARE_WORKERS_ONBOARDING.md
