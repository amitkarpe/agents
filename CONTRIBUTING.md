# Contributing

These rules govern authoring, validating and publishing this knowledge repository.
They do not impose publication rules on projects consuming shared instructions.

## Promotion Flow

1. Capture a candidate outside the public Git repository.
2. Confirm that the idea is reusable and that publication is permitted.
3. Rewrite it as a concise concept with OKF frontmatter.
4. Remove private identifiers, paths, authentication details, and unsupported
   claims.
5. Add official or primary citations for technical claims.
6. Link the concept from the topic index in `README.md`.
7. Run `scripts/validate.sh --self-test` and `scripts/validate.sh`.
8. Review the complete diff as permanently public material before promotion.

## Metadata

Every canonical topic file at the root or in one shallow subject directory,
requires YAML frontmatter with a non-empty `type`. Prefer only metadata that
helps readers assess scope, lifecycle, confidence, and freshness.

Lifecycle status values are `candidate`, `reviewed`, `verified`, and
`deprecated`.

## Scope

Executable workflows belong in their owning automation repositories. This
repository records knowledge about those workflows, not host operations,
credentials, runtime state, or evidence bundles.

## Agent OS Repository Guidance

## Purpose

This repository publishes portable operating knowledge for people and software
agents. Markdown is canonical. Active topics live at the root or in one shallow
subject folder. The old KB taxonomy and duplicate pointer tree are retired.

## Contribution Rules

- Keep content general, reusable, and safe for a public repository.
- Never add credentials, authentication state, private infrastructure details,
  customer information, raw logs, chat transcripts, or local machine paths.
- Rewrite source learning; do not copy private or third-party documents.
- Put external source URLs in a `## Citations` section.
- Use relative Markdown links for repository content.
- Use only `candidate`, `reviewed`, `verified`, or `deprecated` for lifecycle
  status.
- Run `scripts/validate.sh` before committing; it validates canonical root and
  shallow topic documents.

## Context Loading

Use the owning Issue/PR plus its latest relevant authorized delta and current
HEAD for normal continuation. Treat broad repository read orders as
bootstrap/recovery guidance, not a per-handoff checklist.

Reload wider context only when the session lacks usable repository context, a
governing file materially changed, identity/objective is ambiguous, current
context is stale/incomplete/contradictory/unsafe, or a new authority/safety
domain requires it. Canonical detail lives in the indexed **Context Loading
Policy** (`CONTEXT.md`) - load on change, not on
every turn; do not duplicate that policy across repositories.

For a task that actually coordinates G with a coding agent (direct G -> X
or an already selected Factory/Manager -> X), explicitly open the
[G and Coding-Agent Collaboration Protocol](chatgpt/COLLABORATION.md)
**once** when needed. A link or this entrypoint alone does not mean that
external guidance has already been read. Skip for unrelated work and reuse
verified warm context; the owning Issue, local SPEC and approvals override
reusable guidance.

## Ownership

Agent OS is the canonical home for sanitized, reusable, cross-project operating
knowledge: principles, policies, repeatable playbooks, dated observations, and
the lifecycle used to promote or retire that knowledge.

Ownership roles:

- **Amit** is the policy owner and final decision-maker for durable global
  standards and public promotion.
- **G / ChatGPT** is the curator/controller: identify reusable candidates, check
  for an existing canonical concept, propose sanitized promotion, and check
  cross-repository consistency.
- **X / Codex or repository workers** may implement and validate approved
  changes; implementation authority does not imply policy or publication
  authority.

G is also the portfolio controller for `agent-os`, `repo-starter`, and
`dotfiles`. This role belongs to G, not to one chat session: reconstruct it from
GitHub truth. Periodically triage open work, deduplicate or close stale work,
identify reusable learning, canonicalize it in Agent OS, and propagate only
universal repository defaults to `repo-starter` or local/runtime guidance to
`dotfiles`. Amit remains the final human authority; X implements or validates
when delegated.

Repository responsibilities stay separate:

- `agent-os` owns reusable public knowledge and the promotion model.
- `repo-starter` is a downstream distribution baseline for the smallest
  mandatory defaults new or retrofitted repositories should start with. It
  should distill or reference Agent OS guidance rather than become a second
  knowledge base.
- `dotfiles` owns local/runtime/tool adapters, host-specific facts, provider
  preferences, and machine-wide operating defaults in its owning host or native
  provider configuration. It may reference Agent OS but should not duplicate
  reusable public policies or depend on the legacy shared-policy tree.
- Project repositories remain authoritative for their own `AGENTS.md`, `SPEC`,
  current context, approvals, implementation, evidence, and runtime truth. They
  are the primary source of new learning candidates.
- `work` and other active repositories may prove or refine a practice, but once
  generalized they are not the final global source of truth.

Candidate material remains outside this public Git repository until it has been
sanitized, reviewed, and deliberately promoted. Keep one canonical home for a
reusable concept; extend or cross-link it instead of copying competing policy.

Use this promotion direction:

`project learning -> reusable candidate -> sanitize/deduplicate -> Agent OS -> repo-starter only when it is a universal repository default`

Critical safety rules may justify proactive retrofit. Normal improvements should
usually propagate to existing repositories when those repositories are next
touched.

KISS: **Learn locally. Generalize once. Store canonically. Distribute minimally.**

## Portfolio Economy Defaults

- Testing: default to **zero new tests**, not zero validation. Use the smallest meaningful existing proof and keep required repository checks. The portable [Testing and Validation](TESTING.md) policy owns conditional details; load it when deciding to add, modify or retire tests, not every turn.
- Git workflows: the portable [Git Workflow](GIT.md) owns bounded Issue/PR and verification conventions. Apply it when repository work needs it, not on every turn; project-specific GitLab/source/merge rules override it.
- Goals and delegation: the portable [Goals and Delegation](GOALS.md) policy owns bounded continuation, helper boundaries, evidence and stop gates. Apply it when coordinating or executing agent work; provider/runtime details remain local.
- Shared core and tools: the portable [Shared Agent Instructions](AGENTS.md) and [Tool Routing](TOOLS.md) policies own authority/context separation and proportionate tool selection. Keep provider, host and authentication details local.
- Runners: public repositories may use standard GitHub-hosted runners such as `ubuntu-latest`. Private repositories should avoid GitHub-hosted runners by default and reuse an existing approved CodeBuild/CodePipeline or CodeBuild-hosted Actions runner; do not create new CI infrastructure merely to replace a free public runner.
- Worktrees: when a PR/Issue closes, review related local worktrees and remove completed, clean, unused **secondary** worktrees only after their work is merged/preserved and no active Codex session, rollback, or uncommitted/untracked work depends on them. Prefer native `git worktree remove` (never `rm -rf` or `--force` by default); leave active, dirty, uncertain, or unmerged work untouched. Batch already-safe cleanup if useful, but do not accumulate abandoned checkouts. Codex 0.162.0 adds managed **create/list** tools behind its worktrees feature; this does **not** imply automatic deletion.

## Citations

- [Codex 0.162.0 managed worktree create/list](https://github.com/openai/codex/releases/tag/rust-v0.162.0)
- [Git native worktree remove and prune](https://git-scm.com/docs/git-worktree)
