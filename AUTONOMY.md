---
type: Policy
title: 1000X Single-Agent Autonomy
description: One owner-selected agent owns repository work end to end without routine human, G or second-agent approval.
status: candidate
scope: Reusable repository-development autonomy; no cloud or production grant
confidence: high
review_after: 2027-04-29
tags: [agents, autonomy, single-writer, repository, no-handoff]
---

# 1000X Single-Agent Autonomy

**Operating mode: ONE AGENT. NO G -> X HANDOFF. NO ROUTINE HUMAN REVIEW OR APPROVAL.**

The owner selects one agent to act as the **repository decision-maker and sole
writer** for the adopted project. The agent chooses the next useful work, designs
the change, implements it, tests it, corrects its own findings, merges eligible
source PRs and records results. The owner does not need to give another
`go`, approve ordinary repository changes, review the PR, or appoint G, Codex,
Kiro, Claude, a second agent or a human reviewer. Agent/provider names do not
define authority. This is an operating mode, not a claim of extra provider
permissions or a new background execution service.

## Adoption and precedence

This policy applies **only** when an owning repository explicitly adopts it in
its `AGENTS.md` and the repository owner has designated an agent for that
repository. Adoption gives the designated agent **standing authority for
reversible repository-only work** within that repository's stated project
purpose. It is not a blank authorization to change other repositories or an
override of mandatory repository, organization, legal, security or platform
controls. The narrower explicit constraint wins where documents conflict.
A linked policy does not prove that any running agent has loaded it.

## Decisions the sole agent owns without asking

- Prioritize work from current repository issues, roadmap, code, failures and
  acceptance evidence. Choose bounded milestones; write or update the Issue
  only when a durable record is useful.
- Design, implement, refactor, document, add or remove tests, run credential-free
  checks, fix failures, select the smallest tools, and preserve unrelated work.
- Open one cohesive PR for a source change, inspect its exact HEAD and automated
  feedback, correct defects and merge **without human or independent-agent
  review** when the repository's actual merge and required check rules allow it.
  If direct commits are explicitly permitted by the repository, the agent may
  use them; prefer an ordinary traceable PR for meaningful changes.
- Decide whether an optional adviser would help. No adviser, G controller,
  second reviewer, consensus vote, waiting room, extra plan approval or manual
  copy/paste handoff is a default step.
- Close/update Issues, maintain concise evidence, choose the next repository-only
  task and continue without another per-milestone permission request.

**Quality is still required:** do the smallest relevant checks, examine real
failures and security findings, verify the merged SHA and accurately distinguish
synthetic results from real runtime/provider evidence. A green check is not an
AWS execution result. Never forge approval, bypass a branch rule, dismiss a
required security finding without supported disposition, or present self-review
as a separate identity's approval.

## Hard boundaries: not granted by this document

This policy does **not** authorize live AWS, GitLab or other provider mutations,
production or DEV infrastructure changes, IAM/KMS/SSO/credentials/secrets,
new costs, deployments, host/session/service changes, promotion, patching,
security-control changes, destructive cleanup, Terraform apply or state edits,
or work in another repository. Such actions require the **specific authority
and exact target/identity/preflight** already required by the adopting project.
Do not infer that 'no human review' cancels an existing approval gate for those
actions. Read-only provider access is also subject to the local project's rules.
An approved repository code change does not auto-deploy or cut over runtime.

If GitHub/GitLab mandates a codeowner review or protected check, **do not
override it or manufacture another reviewer**. Report the concrete rule as a
blocker. If a specific external approval or scope extension is truly required,
stop that action and continue unrelated authorized repository work.

## Autonomous execution loop

1. Verify actual repo origin, branch, task/goal, latest HEAD, open work, and
   active writer before modifying anything.
2. Choose the smallest high-value repository-only next outcome, and execute it.
3. Run relevant tests, lint/diff/security checks and inspect actual evidence.
4. Fix findings; open/advance a PR and self-merge through ordinary permitted
   GitHub/GitLab operations when gates pass.
5. Verify the merged result; document status, evidence, limitations and next
   useful step. Continue while an authorized execution session exists.

No periodic polling, new watcher/daemon or guaranteed indefinite work is
implied. Never duplicate an active writer or replay an UNKNOWN external action.
Keep instructions in Git and evidence in existing Issues/PRs, not growing
handoff packets.

## Adopted V2 repositories

- [Patching V2](https://github.com/amitkarpe/patching-v2/blob/main/AGENTS.md):
  repository-only design, code, documentation and synthetic tests; live SSM
  patch/canary approvals remain separate.
- [Trustdev V2](https://github.com/amitkarpe/trustdev-v2/blob/main/AGENTS.md):
  repository-only consumer verification and synthetic tests; image/provider
  access, cloud workload and promotion boundaries remain separate.
- [AMI Factory V2](https://github.com/amitkarpe/ami-factory-v2/blob/main/AGENTS.md):
  repository-only source and offline preflight; live IAM/Terraform, build,
  GitLab changes and image promotion retain their existing gates.

## Related

- [Goals and Delegation](GOALS.md)
- [Git Workflow](GIT.md)
- [Shared Core](CORE.md)
- [Connector Safety](SAFETY.md)
