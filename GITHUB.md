---
type: Policy
title: GitHub PR Review and Codex Feedback
description: Capture Codex's PR feedback before autonomous merges, without an extra approval loop.
status: candidate
scope: Reusable GitHub-only review discipline when Codex auto-review is enabled
confidence: high
timestamp: 2026-11-02T17:00:00+08:00
review_after: 2027-05-02
tags: [github, codex, pull-requests, review, autonomy]
---

# GitHub PR Review and Codex Feedback

Use this for GitHub pull requests in repositories with Codex automatic review
enabled or explicitly requested by the owner. An Issue is an intake item,
**not** a Codex code-review event. Keep portable Git operations and GitLab
workflows in [GIT.md](GIT.md).

## Shared GitHub API quota

**Shared GitHub API quota:** Reuse/collapse redundant GraphQL lookups, bound filtered results, and avoid duplicate polling/watchers across agents using the same identity; when rate-limited, record the provider's actual reset or `Retry-After` and pause affected calls rather than retrying repeatedly.

## Before an authorized merge

1. Publish a **ready-for-review** PR when the changes are actually ready.
   Record its exact head commit SHA. Do not assume a draft PR triggers Codex.
2. Allow for Codex's review: first look after roughly **3 minutes** (an
   observed typical latency, not a service guarantee); check again within
   a **5-minute** initial window. Use actual GitHub readback, not elapsed
   time, a green CI result or an agent's expectation.
3. Inspect both the Codex PR review summary and inline review threads.
   The summary may be posted by `chatgpt-codex-connector[bot]` with
   `codex-pull-request-review-summary`; where supplied, match its
   `code_review.commit_sha` to the current PR head. No bot comment,
   no current-head match, or an unfinished review means **REVIEW_PENDING**.
4. Address actionable P1/P2 and higher-severity findings or explain with
   evidence why a finding does not apply. Check inline threads as well as
   the summary. Do not confuse "no findings" with "no review".
5. If a material fix changes HEAD, check whether Codex review for the
   **new** head has already started or completed. If not, check for an
   existing request, then comment `@codex review` **once** on the PR and
   use the same bounded wait and readback above. Reconcile an in-progress
   request instead of posting duplicates. Feedback on an older commit is
   not proof that the updated diff was reviewed.
6. Merge autonomously **only** when current-head review feedback has been
   evaluated, the required checks pass, the PR remains in authorized scope,
   and branch/ruleset protections permit the merge. No routine owner GO
   or Codex approval vote is added.

## If the review does not arrive

After the initial **5-minute** budget, leave the PR at `REVIEW_PENDING`
and continue unrelated authorized work. Reconcile that same PR later;
do not start duplicate reviewers, claim a pass, or use the timeout as an
automatic merge exemption. If review delivery remains unavailable, report
the specific blocker and obtain the owning project's explicit exception
before merging without this feedback.

## Boundaries

This is a review-evidence rule, **not** a new cloud permission, a reviewer
veto, a general second-writer requirement, or a substitute for CI/provider
readback. Keep one active implementation writer per branch or bounded task;
Claude, Kiro or Codex may implement separately when an owner-selected
orchestrator assigns non-overlapping work.

The GitHub-native summary and inline comments are the durable result.
Do not add another workflow, timer service, status file or review bot just
to implement this convention unless an actual missed-review pattern needs
mechanical enforcement.

## Citations

- [GitHub GraphQL API rate limits](https://docs.github.com/en/graphql/overview/rate-limits-and-query-limits-for-the-graphql-api)
